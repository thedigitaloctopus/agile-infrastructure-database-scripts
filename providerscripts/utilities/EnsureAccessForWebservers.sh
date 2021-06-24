#!/bin/sh
##################################################################################
# Description: This ensures that if, as is the case with some providers, webservers
# are deployed which have a different ip address range than the first webserver that
# was deployed and therefore a different ipmask, that these webserver(s) are
# granted access to the database as needed. This is done by monitoring the active ip
# addresses and updating the access mask in the database. This way, we can be sure
# that all webservers are granted access irrespective of any ip address differences.
# This script ensures that the webservers all have access to the database.
# Author: Peter Winter
# Date: 25/06/2017
#################################################################################
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
##################################################################################
###################################################################################set -x
#set -x

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    for webserverip in `/bin/ls ${HOME}/config/webserverips`
    do
        ipmask="`/bin/echo ${webserverip} | /usr/bin/cut -d "." -f -2`.%.%"
      #  if ( [ "`/bin/ls  ${HOME}/.ssh/CLOUDHOST:* | /usr/bin/awk -F':' '{print $NF}'`" = "exoscale" ] )
      #  then
      #      ipmask="10.0.%.%"
      #  fi 
        /usr/bin/mysql -u ${DB_U} -p${DB_P} -e "GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${ipmask}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;"
    done
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
    postgres_config="`/usr/bin/find / -name pg_hba.conf -print`"
    for webserverip in `/bin/ls ${HOME}/config/webserverips`
    do
        ipmask="`/bin/echo ${webserverip} | /usr/bin/cut -d "." -f -2`.%.%"
        
      #  if ( [ "`/bin/ls  ${HOME}/.ssh/CLOUDHOST:* | /usr/bin/awk -F':' '{print $NF}'`" = "exoscale" ] )
      #  then
      #      ipmask="10.0.%.%"
      #  fi 
        
        ipmask="`/bin/echo ${ipmask} | /bin/sed 's/%/0/g'`"

        if ( [ "`/bin/cat ${postgres_config} | /bin/grep ${DB_N} | /bin/grep ${ipmask}`" = "" ] )
        then
            ipmask="`/bin/echo ${webserverip} | /usr/bin/cut -d "." -f -2`"
            /bin/echo "host       ${DB_N}              ${DB_U}            ${ipmask}.0.0/0          md5" >> ${postgres_config}
            /usr/sbin/service postgresql reload
            if ( [ "$?" != "0" ] )
            then
                /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl reload -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
            fi
        fi
    done
fi
