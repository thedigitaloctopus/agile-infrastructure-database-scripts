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
versions="`/usr/bin/wget -O - mariadb.org/download | /bin/grep -Eo 'release=[0-9]+\.[0-9]+\.[0-9]+'  | /bin/grep -v 10.7 | /usr/bin/sort -Vr | /bin/sed 's/release=//g'`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y install software-properties-common dirmngr
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:20.04`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:22.04`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        for version in ${versions}
        do
            version="`/bin/echo ${version} | /bin/awk -F'.' '{print $1"."$2}'`"
            /usr/bin/add-apt-repository "deb [arch=amd64] https://mirrors.ukfast.co.uk/sites/mariadb/repo/${version}/ubuntu focal main"
            ${HOME}/installscripts/Update.sh ${BUILDOS}
            if ( [ "$?" != "0" ] )
            then
                /bin/sed -i '/ukfast/d'  /etc/apt/sources.list
            else
                /bin/echo "mariadb-server-${version} mysql-server/root_password password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                /bin/echo "mariadb-server-${version} mysql-server/root_password_again password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                break
           fi
        done        
    fi

    ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
    /usr/bin/apt-get -qq -y install mariadb-client
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get -qq -y remove --purge mysql*
    /usr/bin/apt-get -qq -y remove --purge mariadb*
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y install software-properties-common dirmngr
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:10`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
        
        for version in ${versions}
        do
            version="`/bin/echo ${version} | /bin/awk -F'.' '{print $1"."$2}'`"
            /usr/bin/add-apt-repository "deb [arch=amd64,arm64,ppc64el] https://mirrors.ukfast.co.uk/sites/mariadb/repo/${version}/debian buster main"
            ${HOME}/installscripts/Update.sh ${BUILDOS}
            if ( [ "$?" != "0" ] )
            then
               /bin/sed -i '/ukfast/d'  /etc/apt/sources.list
            else
                /bin/echo "mariadb-server-${version} mysql-server/root_password password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                /bin/echo "mariadb-server-${version} mysql-server/root_password_again password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                break
            fi
        done
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDOSVERSION:11`" = "1" ] )
    then
        /usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
        for version in ${versions}
        do
            version="`/bin/echo ${version} | /bin/awk -F'.' '{print $1"."$2}'`"
            /usr/bin/add-apt-repository "deb [arch=amd64,arm64,ppc64el] https://mirrors.ukfast.co.uk/sites/mariadb/repo/${version}/debian bullseye main"
            ${HOME}/installscripts/Update.sh ${BUILDOS}
            if ( [ "$?" != "0" ] )
            then
               /bin/sed -i '/ukfast/d'  /etc/apt/sources.list
            else
                /bin/echo "mariadb-server-${version} mysql-server/root_password password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                /bin/echo "mariadb-server-${version} mysql-server/root_password_again password ${DB_P}" | /usr/bin/debconf-set-selections > /dev/null
                break
            fi
        done
    fi
    
    ${HOME}/installscripts/Update.sh ${BUILDOS}
    ${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
    /usr/bin/apt-get -qq -y install mariadb-client
fi

