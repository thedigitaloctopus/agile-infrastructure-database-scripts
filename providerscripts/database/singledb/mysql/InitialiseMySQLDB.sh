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
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    HOST="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    HOST="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    HOST="`/bin/ls ${HOME}/.ssh/MYPUBLICIP:* | /usr/bin/awk -F':' '{print $NF}'`"
fi


ipmask="`/bin/ls ${HOME}/.ssh/IPMASK:* | /usr/bin/awk -F':' '{print $NF}'`"
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
CLOUDHOST="`/bin/ls ${HOME}/.ssh/CLOUDHOST:* | /usr/bin/awk -F':' '{print $NF}'`"
ipaddress="`/bin/ls ${HOME}/.ssh/MYPUBLICIP:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] && [ "${CLOUDHOST}" = "aws" ] )
then
    /bin/echo "use mysql;
update user set user=\"${DB_U}\" where user='root';
flush privileges;
create database ${DB_N};
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'localhost' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'127.0.0.1' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${ipmask}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
flush privileges;" > ${HOME}/runtime/initialiseDB.sql
else
/bin/echo "use mysql;
CREATE USER \"${DB_U}\"@'localhost' IDENTIFIED BY '${DB_P}';
CREATE USER \"${DB_U}\"@'127.0.0.1' IDENTIFIED BY '${DB_P}';
CREATE USER \"${DB_U}\"@'${HOST}' IDENTIFIED BY '${DB_P}';
CREATE USER \"${DB_U}\"@'${ipmask}' IDENTIFIED BY '${DB_P}';
flush privileges;
create database ${DB_N};
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'127.0.0.1' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${ipmask}\" WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED WITH BY '${DB_P}';
flush privileges;" > ${HOME}/runtime/initialiseDB.sql
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/initialiseDB.sql
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} --host="127.0.0.1" --port="${DB_PORT}" < ${HOME}/runtime/initialiseDB.sql
else
    #make sure database has been started and is available - this is local instance under our full control
    /usr/sbin/service mysql start
    #try with no password set
    /usr/bin/mysql -A < ${HOME}/runtime/initialiseDB.sql
    #make sure by trying with password
    /usr/bin/mysql -A -u root -p${DB_P} < ${HOME}/runtime/initialiseDB.sql
fi

#if ( [ -f /etc/mysql/my.cnf ] )
#then
#    /bin/sed -i.bak '/bind-address/d' /etc/mysql/my.cnf
#    /bin/sed -i.bak "s/3306/${DB_PORT}/" /etc/mysql/my.cnf
#fi

if ( [ "`/bin/cat /etc/mysql/my.cnf | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/echo "[mysqld]" >> /etc/mysql/my.cnf
    /bin/echo "port        = ${DB_PORT}" >> /etc/mysql/my.cnf
    /bin/echo "bind-address        = 0.0.0.0" >> /etc/mysql/my.cnf
    /bin/echo "default-authentication-plugin = mysql_native_password" >> /etc/mysql/my.cnf
fi

/usr/sbin/service mysqld restart
