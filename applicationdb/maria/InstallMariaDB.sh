#!/bin/sh
########################################################################################################
# Description: This script will install an application SQL codebase into a MariaDB Database
# Author: Peter Winter
# Date: 17/01/2017
########################################################################################################
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

CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"

fi

. ${HOME}/applicationdb/maria/CustomiseMariaByApplication.sh
   
if ( [ "`/bin/ls ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql`" != "" ] )
then
    currentengine="`/bin/grep ENGINE= ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /usr/bin/awk -F' ' '{print $2}' | /usr/bin/head -1`"
    # We are a mysql cluster so we need to use NDB engine type the way to do this is to modify the dump file
    /bin/sed -i "s/${currentengine}/ENGINE=INNODB /g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        /bin/sed -i '/sql_require_primary_key/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        /bin/sed -i '/^\[mysqld\]/a character-set-server = utf8mb4' /etc/mysql/my.cnf
        /bin/sed -i '/^\[mysqld\]/a collation-server = utf8mb4_bin' /etc/mysql/my.cnf        
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] && ( [ "${CLOUDHOST}" = "digitalocean" ] || [ "${CLOUDHOST}" = "exoscale" ] || [ "${CLOUDHOST}" = "aws" ] ) )
    then
        /bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
            /bin/sed -i '1s/^/SET SESSION sql_require_primary_key = 0;\n/' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
            /bin/sed -i '/sql_require_primary_key/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
            if ( [ "`/bin/grep GTID ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql`" != "" ] )
            then
                /bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
                /bin/sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
            fi
        fi
    fi

    #Not sure why but sometimes installation of the application is truncated leaving only a partial set of tables installed
    #so try installing it several in the hope that one succeeds

    lockfile=${HOME}/config/dbinstalllock.file

    if ( [ ! -f ${lockfile} ] )
    then
        /usr/bin/touch ${lockfile}
        /usr/bin/mysql -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port=${DB_PORT} ${DB_N} < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        /bin/rm ${lockfile}
    else
        exit
    fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
    /bin/echo "Something went wrong with obtaining the DB archive, can't run without it..... The END" >> ${HOME}/logs/MonitoringLog.dat
    ${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS FAILED" "Please review your logs as the system has failed to install your database application"
    exit
fi

#Make absolutely certain we are all on INNODB
tables="`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'show tables' | /usr/bin/tail -n +2`"
/bin/echo ${tables}

for table in ${tables}
do
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "ALTER TABLE ${table} ENGINE = INNODB;"
done

if ( [ "`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'show tables' | /usr/bin/wc -l`" -gt "5" ] )
then
    /bin/echo "${0} `/bin/date` : An application has been installed in the database" >> ${HOME}/logs/MonitoringLog.dat
    ${HOME}/providerscripts/email/SendEmail.sh "A new application has been installed in your database" "A new application has been installed in your database"
    /bin/touch ${HOME}/config/APPLICATION_INSTALLED
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
    /bin/echo "${0} `/bin/date` : FAILED TO INSTALL DATABASE - Exiting build sequence" >> ${HOME}/logs/MonitoringLog.dat
    ${HOME}/providerscripts/email/SendEmail.sh "Failed to install a new application in your database" "Failed to install a new application in your database"
    exit
fi
