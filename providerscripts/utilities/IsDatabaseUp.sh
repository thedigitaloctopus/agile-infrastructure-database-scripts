#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 10/4/2016
# Description : Check if the database is up and running
#####################################################################################
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

if (  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS-secured`" = "1" ] )
then
    HOST="127.0.0.1"
elif (  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/GetIP.sh`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

 [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] 

if (  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] ||  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P}  ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'exit'
fi

if (  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] ||  [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${host} -p ${DB_PORT} ${DB_N} -c "\q"
fi

if ( [ "$?" = "0" ] )
then
    /bin/echo "ALIVE"
else
    /bin/echo "DEAD"
fi



