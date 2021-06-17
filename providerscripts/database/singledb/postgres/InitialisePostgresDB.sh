#!/bin/sh
########################################################################################
# Description: This script will install a postgres database
# Author: Peter Winter
# Date: 15/01/2017
########################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
####################################################################################
####################################################################################
set -x

OUT_FILE="postie-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${OUT_FILE}
ERR_FILE="postie-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${ERR_FILE}

ipmask="`/bin/ls ${HOME}/.ssh/IPMASK:* | /usr/bin/awk -F':' '{print $NF}'`"
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
CLOUDHOST="`/bin/ls ${HOME}/.ssh/CLOUDHOST:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    HOST="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    HOST="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    HOST="`/bin/ls ${HOME}/.ssh/MYIP:* | /usr/bin/awk -F':' '{print $NF}'`"
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
    postgres_config="`/usr/bin/find / -name pg_hba.conf -print`"
    postgres_pid="`/usr/bin/find / -name postmaster.pid -print`"
    postgres_sql_config="`/usr/bin/find / -name postgresql.conf -print | /bin/grep etc`"
    if ( [ "${postgres_sql_config}" = "" ] )
    then
        postgres_sql_config="`/usr/bin/find / -name postgresql.conf -print`"
    fi

    /bin/rm ${postgres_pid}
  #  /bin/sed -i 's/md5/trust/g' ${postgres_config}
    /bin/sed -i "/listen_addresses/c\        listen_addresses = '*'" ${postgres_sql_config}
    /bin/sed -i "/^port/c\        port = ${DB_PORT}" ${postgres_sql_config}
    /bin/sed -i "/^#port/c\        port = ${DB_PORT}" ${postgres_sql_config}

    ipmask="`/bin/echo ${ipmask} | /bin/sed 's/%/0/g'`"
    
    /bin/sed -i '/127.0.0.1/d' ${postgres_config}
    /bin/sed -i '/128/d' ${postgres_config}

    
    if ( [ "${CLOUDHOST}" = "aws" ] )
    then
        /bin/echo "host       ${DB_N}              ${DB_U}            0.0.0.0/0          md5" >> ${postgres_config}
    else
        /bin/echo "host       ${DB_N}              ${DB_U}            ${ipmask}/16          md5" >> ${postgres_config}
        /bin/echo "host       all              postgres            127.0.0.1/32         trust" >> ${postgres_config}
    fi

    /usr/sbin/service postgresql restart
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/systemctl restart rc-local.service
    fi
    
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE USER ${DB_U} WITH ENCRYPTED PASSWORD '${DB_P}';"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "ALTER USER ${DB_U} WITH SUPERUSER;"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
    if ( [ "$?" != "0" ] )
    then   
        /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8' TEMPLATE template0;"
    fi
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_N} to ${DB_U};"

    /bin/sed -i "s/trust/md5/g" ${postgres_config}

    /bin/rm ${postgres_pid}
            
   /usr/sbin/service postgresql reload
   if ( [ "$?" != "0" ] )
   then
       /usr/bin/systemctl restart rc-local.service
   fi

elif ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';"
    if ( [ "$?" != "0" ] )
    then
        export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';"
    fi
fi
