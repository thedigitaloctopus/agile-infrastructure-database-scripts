#!/bin/sh
###################################################################################
# Description: This  will install the mysql client
# Date: 18/11/2016
# Author : Peter Winter
###################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "" ] )
then
    BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"
fi
BUILDOSVERSION="`/bin/ls ${HOME}/.ssh/BUILDOSVERSION:* | /usr/bin/awk -F':' '{print $NF}'`"

DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    /usr/bin/wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
    DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i mysql-apt-config*
    /bin/rm mysql-apt-config*
    ${HOME}/installscripts/Update.sh ${BUILDOS}
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install mysql-client
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
    DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i mysql-apt-config*
    /bin/rm mysql-apt-config*
    ${HOME}/installscripts/Update.sh ${BUILDOS}
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install mysql-client
fi