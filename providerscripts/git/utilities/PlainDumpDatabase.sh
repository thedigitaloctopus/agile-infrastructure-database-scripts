#!/bin/sh
##############################################################################################################################
# Description: This script implements database specific dump procedures. If you want to support additional new types of
# database, then, you can add to this file, for example, mongodb or something like that
# Author: Peter Winter
# Date: 28/05/2017
##############################################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    HOST="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    HOST="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    HOST="`${HOME}/providerscripts/utilities/GetIP.sh`"
fi

#The standard troop of SQL databases
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] )
then    
    /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y  --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} > applicationDB.sql
    /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8;" >> applicationDB.sql
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] )
then
    /usr/bin/mysqldump --lock-tables=false --no-tablespaces -y --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} > applicationDB.sql
    /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8;" >> applicationDB.sql
fi

#The Postgres SQL database
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/pg_dump -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} > applicationDB.sql
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/sudo -su postgres /usr/bin/pg_dump -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.sql
    fi
    /bin/echo "CREATE TABLE public.zzzz ( idxx serial PRIMARY KEY );" >> applicationDB.sql
fi
