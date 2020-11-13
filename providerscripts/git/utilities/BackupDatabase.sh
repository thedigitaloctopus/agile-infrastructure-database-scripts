#!/bin/sh
##############################################################################################################################
# Description: This script implements database specific backup procedures. If you want to support additional new types of
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

DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

#The standard troop of SQL databases
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] )
then
    #Dump the database to an sql file
    if ( [ "`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'show tables' | /usr/bin/wc -l`" -lt "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Failed to backup database, it seems like the tables are not there" >> ${HOME}/logs/MonitoringLog.dat
        exit
    fi
    
    /bin/echo "SET SESSION sql_require_primary_key = 0;" > applicationDB.sql
    /bin/echo "DROP TABLE IF EXISTS \`zzzz\`;" >> applicationDB.sql
    /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y --host=${HOST} --port=${DB_PORT} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    tries="1"
    while ( [ "${tries}" -lt "5" ] ) || [ "$?" != "0"  ] )
    do
        /bin/sleep 10
        tries="`/usr/bin/expr ${tries} + 1`"
        /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y --host=${HOST} --port=${DB_PORT} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    done

    /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8;" >> applicationDB.sql
    /bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.sql
    /bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.sql
    /bin/sed -i '/SESSION.SQL_LOG_BIN/d' applicationDB.sql
    ipmask="`/bin/ls ${HOME}/.ssh/IPMASK:* | /usr/bin/awk -F':' '{print $NF}'`"
    /bin/sed -i "s/${ipmask}/YYYYYYYYYY/g" applicationDB.sql
    /bin/echo "${0} `/bin/date`: replaced all http with https in the SQL file" >> ${HOME}/logs/MonitoringLog.dat
    /bin/echo "${0} `/bin/date`: Taring the database dump" >> ${HOME}/logs/MonitoringLog.dat

    #tar the database dump
    /bin/tar cvfz ${websiteDB} applicationDB.sql
    /bin/rm applicationDB.sql
fi

#The postgres SQL database
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
then
    /bin/echo "DROP TABLE zzzz;" > applicationDB.sql
    export PGPASSWORD="${DB_P}" && /usr/bin/pg_dump -U ${DB_U} -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.sql
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/sudo -su postgres /usr/bin/pg_dump -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.sql
    fi
    /bin/echo "CREATE TABLE public.zzzz ( idxx serial PRIMARY KEY );" >> applicationDB.sql
    /bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.sql
    /bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.sql
    ipmask="`/bin/ls ${HOME}/.ssh/IPMASK:* | /usr/bin/awk -F':' '{print $NF}'`"
    /bin/sed -i "s/${ipmask}/YYYYYYYYYY/g" applicationDB.sql
    /bin/echo "${0} `/bin/date`: replaced all http with https in the SQL file" >> ${HOME}/logs/MonitoringLog.dat
    /bin/echo "${0} `/bin/date`: Taring the database dump" >> ${HOME}/logs/MonitoringLog.dat
    /bin/tar cvfz ${websiteDB} applicationDB.sql
    /bin/rm applicationDB.sql
fi
