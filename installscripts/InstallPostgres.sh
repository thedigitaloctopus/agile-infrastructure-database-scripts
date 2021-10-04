#!/bin/sh
###################################################################################
# Description: This  will install postgres
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

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'POSTGRES:source'`" = "1" ] )
    then
        /usr/sbin/locale-gen UTF-8
        ${HOME}/installscripts/postgres/InstallPostgresFromSource.sh
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'POSTGRES:repo'`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y update
        /usr/sbin/locale-gen UTF-8
        /usr/bin/apt-get -qq -y install postgresql postgresql-contrib
        version="`/bin/ls /etc/postgresql/`"
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${version}/bin/postgres -D /var/lib/postgresql/${version}/main -c config_file=/etc/postgresql/${version}/main/postgresql.conf
        /usr/sbin/service postgresql restart
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'POSTGRES:source'`" = "1" ] )
    then
        /usr/sbin/locale-gen UTF-8
        ${HOME}/installscripts/postgres/InstallPostgresFromSource.sh    
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'POSTGRES:repo'`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y update
        /usr/sbin/locale-gen UTF-8
        /usr/bin/apt-get -qq -y install postgresql postgresql-contrib
        version="`/bin/ls /etc/postgresql/`"
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${version}/bin/postgres -D /var/lib/postgresql/${version}/main -c config_file=/etc/postgresql/${version}/main/postgresql.conf
        /usr/sbin/service postgresql restart
    fi
fi

