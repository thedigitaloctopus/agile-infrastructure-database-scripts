#!/bin/sh
######################################################################################################
# Description: If the Maria Database needs any settings specific to an application, they can set here.
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################
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
#####################################################################################################
#####################################################################################################
#set -x

HOST=""
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    HOST="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    HOST="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    HOST="localhost"
fi



if ( [ -f ${HOME}/.ssh/APPLICATION:moodle ] )
then
    #  /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="127.0.0.1" --port="${DB_PORT}" -e "SET GLOBAL innodb_file_format=Barracuda;"
    #  /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="127.0.0.1" --port="${DB_PORT}" -e "SET GLOBAL innodb_file_per_table=ON;"
    #  /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="127.0.0.1" --port="${DB_PORT}" -e "SET GLOBAL INNODB_DEFAULT_ROW_FORMAT=DYNAMIC;"
    #  /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="127.0.0.1" --port="${DB_PORT}" -e "SET GLOBAL innodb_large_prefix=1;"
    #  /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="127.0.0.1" --port="${DB_PORT}" -e "SET GLOBAL binlog_format = 'MIXED';"
    /bin/sed -i '/^\[mysqld\]/a binlog_format=mixed' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_large_prefix=1' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_file_per_table=ON' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_default_row_format=dynamic' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_file_format=Barracuda' /etc/mysql/my.cnf
fi