#!/bin/sh
####################################################################################
# Description: This script will extract an IP mask for our webservers which means
# we can grant privileges in the database to our webservers using their common ip mask. 
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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "0" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "0" ] )
then
   exit
fi

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

ips="`/bin/ls ${HOME}/config/webserverips`"

if ( [ "${ips}" = "" ] )
then
    exit
fi

for ip in ${ips}
do
    IPMASK="`/bin/echo $ip | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`"
    IPMASK=${IPMASK}".%.%" 
    /usr/bin/mysql -A -u root -p${DB_P} --host="localhost" --port="${DB_PORT}" -e "CREATE USER \"${DB_U}\"@'${IPMASK}' IDENTIFIED BY '${DB_P}';"
    /usr/bin/mysql -A -u root -p${DB_P} --host="localhost" --port="${DB_PORT}" -e "GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${IPMASK}\" WITH GRANT OPTION;"
done
