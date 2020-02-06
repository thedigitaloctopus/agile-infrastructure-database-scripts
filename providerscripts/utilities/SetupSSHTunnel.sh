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

DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
DBaaS_HOSTNAME="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
DBaaS_REMOTE_SSH_PROXY_IP="`/bin/ls ${HOME}/.ssh/DBaaSREMOTESSHPROXYIP:* | /usr/bin/awk -F':' '{print $NF}'`"
DEFAULT_DBaaS_OS_USER="`/bin/ls ${HOME}/.ssh/DEFAULTDBaaSOSUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "`/bin/ps -ef | /bin/grep "${DBaaS_HOSTNAME}" | /bin/grep -v 'grep'`" != "" ] )
then
    exit
fi

if ( [ ! -f /usr/bin/autossh ] )
then
    ${HOME}/installscripts/InstallAutoSSH.sh ${BUILDOS}
fi

/usr/bin/autossh -M 0 -o StrictHostKeyChecking=no -fN -L ${DB_PORT}:${DBaaS_HOSTNAME}:${DB_PORT} -p 22 -i ${HOME}/.ssh/dbaas_server_key.pem ${DEFAULT_DBaaS_OS_USER}@${DBaaS_REMOTE_SSH_PROXY_IP}
