#!/bin/sh
###########################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will set up an SSH tunnel to a remote ip address. It is intended
# for use to connect to a remote database in a secured way.
###########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"
DBaaS_HOSTNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
DBaaS_REMOTE_SSH_PROXY_IP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSREMOTESSHPROXYIP'`"
DEFAULT_DBaaS_OS_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DEFAULTDBaaSOSUSER'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

if ( [ "`/bin/ps -ef | /bin/grep "${DBaaS_HOSTNAME}" | /bin/grep -v 'grep'`" != "" ] )
then
    exit
fi

if ( [ ! -f /usr/bin/autossh ] )
then
    ${HOME}/installscripts/InstallAutoSSH.sh ${BUILDOS}
fi

/usr/bin/autossh -M 0 -o StrictHostKeyChecking=no -fN -L ${DB_PORT}:${DBaaS_HOSTNAME}:${DB_PORT} -p 22 -i ${HOME}/.ssh/dbaas_server_key.pem ${DEFAULT_DBaaS_OS_USER}@${DBaaS_REMOTE_SSH_PROXY_IP}
