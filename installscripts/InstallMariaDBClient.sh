#!/bin/sh
###################################################################################
# Description: This  will install mariadb
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
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
fi

BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
version="`/usr/bin/curl https://downloads.mariadb.org/ | /bin/grep stable | /usr/bin/head -1 | /bin/sed 's/[^0-9.]*//g' | /bin/sed 's/\./ /g' | /usr/bin/xargs | /bin/sed 's/ /./g'`"

DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    /bin/echo "mariadb-server-${version} mysql-server/root_password password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
    /bin/echo "mariadb-server-${version} mysql-server/root_password_again password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
    /usr/bin/apt-get -qq -y install software-properties-common dirmngr
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:18.04`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        /usr/bin/add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.4/ubuntu bionic main"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:20.04`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        /usr/bin/add-apt-repository "deb [arch=amd64] http://mirrors.coreix.net/mariadb/repo/${version}/ubuntu focal main"
    fi

    ${HOME}/installscripts/Update.sh ${BUILDOS}
    /usr/bin/apt-get -qq -y install mariadb-client
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get -qq -y remove --purge mysql*
    /usr/bin/apt-get -qq -y remove --purge mariadb*
    
    /bin/echo "mariadb-server-${version} mysql-server/root_password password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
    /bin/echo "mariadb-server-${version} mysql-server/root_password_again password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
    /usr/bin/apt-get -qq -y install software-properties-common dirmngr

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:9`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
        /usr/bin/add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.3/debian stretch main'
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:10`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
        /usr/bin/add-apt-repository "deb [arch=amd64] http://mirrors.coreix.net/mariadb/repo/${version}/debian buster main"
    fi

    ${HOME}/installscripts/Update.sh ${BUILDOS}
    ${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
    /usr/bin/apt-get -qq -y install mariadb-client
fi

