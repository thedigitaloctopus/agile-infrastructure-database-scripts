#!/bin/sh
############################################################################
# Description: This script initialises the mysql db instance ready for use
# Author: Peter Winter
# Date: 15/01/2017
############################################################################
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
#################################################################################
#################################################################################
set -x

HOST=""
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/bin/echo "use mysql;
CREATE USER \"${DB_U}\"@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_P}';
CREATE USER \"${DB_U}\"@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '${DB_P}';
CREATE USER \"${DB_U}\"@'${HOST}' IDENTIFIED WITH mysql_native_password BY '${DB_P}';
CREATE USER \"${DB_U}\"@'${IP_MASK}' IDENTIFIED WITH mysql_native_password BY '${DB_P}';
flush privileges;
create database ${DB_N};
ALTER DATABASE ${DB_N} CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'127.0.0.1' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${IP_MASK}\" WITH GRANT OPTION;
GRANT SESSION_VARIABLES_ADMIN ON *.* TO \"${DB_U}\";
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_P}';
flush privileges;" > ${HOME}/runtime/initialiseDB.sql


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    /bin/sed -i '/GRANT SESSION/d' ${HOME}/runtime/initialiseDB.sql
    /bin/sed -i '/DELETE FROM/d' ${HOME}/runtime/initialiseDB.sql
    /bin/sed -i '/ALTER USER/d' ${HOME}/runtime/initialiseDB.sql    
    /bin/sed -i '/CREATE USER/d' ${HOME}/runtime/initialiseDB.sql
    /usr/bin/mysql -f -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/initialiseDB.sql
else
    #make sure database has been started and is available - this is local instance under our full control
    /usr/sbin/service mysql start
    #try with no password set
    /usr/bin/mysql -f -A < ${HOME}/runtime/initialiseDB.sql
    #make sure by trying with password
    /usr/bin/mysql -f -A -u root -p${DB_P} < ${HOME}/runtime/initialiseDB.sql
fi

if ( [ "`/bin/grep "${DB_PORT}" /etc/mysql/my.cnf`" = "" ] )
then
    /bin/echo "[mysqld]" >> /etc/mysql/my.cnf
    /bin/echo "port        = ${DB_PORT}" >> /etc/mysql/my.cnf
    /bin/echo "bind-address        = 0.0.0.0" >> /etc/mysql/my.cnf
    /bin/echo "default-authentication-plugin = mysql_native_password" >> /etc/mysql/my.cnf
fi

/usr/sbin/service mysqld restart
