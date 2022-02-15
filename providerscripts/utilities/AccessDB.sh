#!/bin/sh
##########################################################################
# Description: This script will tell us if a mysql database is accessible
# Author: Peter Winter
# Date: 15/01/2017
##########################################################################
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
##################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/GetIP.sh`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

DBaaS_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATABASEDBaaSINSTALLATIONTYPE'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`/bin/echo ${DBaaS_INSTALLATION_TYPE} | /bin/grep Maria`" != "" ] )
then
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`/bin/echo ${DBaaS_INSTALLATION_TYPE} | /bin/grep MySQL`" != "" ] )
then
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] ||     [ "`/bin/echo ${DBaaS_INSTALLATION_TYPE} | /bin/grep Postgres`" != "" ] )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${host} -p ${DB_PORT} ${DB_N}
fi
