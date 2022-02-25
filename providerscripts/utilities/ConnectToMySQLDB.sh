#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will connect you to your mysql database
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "databaseip/*"`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "${1}" = "" ] )
then
    /usr/bin/mysql -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
else 
    /usr/bin/mysql -s -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "${1}"
fi
