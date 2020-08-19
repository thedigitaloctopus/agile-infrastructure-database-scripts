#!/bin/sh
####################################################################################
# Description: This will install a single DB node based on the selected DB type
# Date: 18/11/2016
# Author: Peter Winter
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    DBaaS_DBNAME="`/bin/ls ${HOME}/.ssh/DBaaSDBNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
    DBaaS_PASSWORD="`/bin/ls ${HOME}/.ssh/DBaaSPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
    DBaaS_USERNAME="`/bin/ls ${HOME}/.ssh/DBaaSUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"

    /bin/echo "${DBaaS_DBNAME}" >>  ${HOME}/credentials/shit
    /bin/echo "${DBaaS_PASSWORD}" >>  ${HOME}/credentials/shit
    /bin/echo "${DBaaS_USERNAME}" >>  ${HOME}/credentials/shit
else
    RND="n`/bin/cat /dev/urandom | /usr/bin/tr -dc 'a-zA-Z0-9' | /usr/bin/fold -w 8 | /usr/bin/head -n 1 | tr '[:upper:]' '[:lower:]'`n"
    RND1="p`/bin/cat /dev/urandom | /usr/bin/tr -dc 'a-zA-Z0-9' | /usr/bin/fold -w 8 | /usr/bin/head -n 1 | tr '[:upper:]' '[:lower:]'`p"
    RND2="u`/bin/cat /dev/urandom | /usr/bin/tr -dc 'a-zA-Z0-9' | /usr/bin/fold -w 8 | /usr/bin/head -n 1 | tr '[:upper:]' '[:lower:]'`u"

    /bin/echo "${RND}" > ${HOME}/credentials/shit
    /bin/echo "${RND1}" >> ${HOME}/credentials/shit
    /bin/echo "${RND2}" >> ${HOME}/credentials/shit
fi

if ( [ -f ${HOME}/config/credentials/shit ] )
then
    DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
    DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
    DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
else
    DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
    DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
    DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] )
then
    . ${HOME}/providerscripts/database/singledb/mariadb/InstallMariaDB.sh
    . ${HOME}/providerscripts/database/singledb/mariadb/InitialiseMariaDB.sh
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
then
    . ${HOME}/providerscripts/database/singledb/postgres/InstallPostgresDB.sh
    . ${HOME}/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] )
then
    . ${HOME}/providerscripts/database/singledb/mysql/InstallMySQLDB.sh
    . ${HOME}/providerscripts/database/singledb/mysql/InitialiseMySQLDB.sh
fi

#/usr/sbin/service mysql restart
${HOME}/providerscripts/email/SendEmail.sh "A single node database has been started" "a single node database has been started and initialised"
/bin/touch ${HOME}/runtime/DB_INITIALISED
