#!/bin/sh
##########################################################################
# Description: This script will monitor for low disk states and record them on
# the shared filesystem
# Author: Peter Winter
# Date: 15/01/2017
##########################################################################
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
##################################################################################
##################################################################################
#set -x


DISK="`/bin/df -k | grep "/$" | awk '{print $(NF-1)}' | /bin/sed 's/%//'`"
IP="`${HOME}/providerscripts/utilities/GetIP.sh`"

if ( [ ! -d ${HOME}/config/lowdiskaudit/database/${IP} ] )
then
    /bin/mkdir -p ${HOME}/config/lowdiskaudit/database/${IP}
fi

if ( [ "${DISK}" -gt "$1" ] )
then
    /bin/echo "LOW DISK state detected `/bin/date` VALUE: ${DISK} % in use" >> ${HOME}/config/lowdiskaudit/${IP}/lowdiskaudittrail.dat
    ${HOME}/providerscripts/email/SendEmail.sh "LOW DISK STATE DETECTED" "LOW DISK state detected `/bin/date` VALUE: ${DISK}% in use on machine with ip address: `${HOME}/providerscripts/utilities/GetPublicIP.sh`"
fi
