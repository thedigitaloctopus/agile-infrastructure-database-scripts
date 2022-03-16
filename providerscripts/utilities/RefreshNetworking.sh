#!/bin/sh
#####################################################################################
# Description: This will refresh the private networking
# Author: Peter Winter
# Date: 15/01/2017
####################################################################################
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
###################################################################################
###################################################################################
#set -x

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        if ( [ "${BUILDOSVERSION}" = "20.04" ] ||  [ "${BUILDOSVERSION}" = "22.04" ] )
	then
	    IP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYIP'`"
            
	    macaddress="`/usr/bin/ip addr | /bin/grep "link" | /bin/grep "ether" | /usr/bin/tail -1 | /usr/bin/awk '{print $2}'`"
            
            /bin/sed -i "s/macaddress.*/macaddress: ${macaddress}/" /etc/netplan/10-enp6s0.yaml
	    /bin/sed -i "s/addresses.*/addresses: [${IP}\/16]/" /etc/netplan/10-enp6s0.yaml

            /usr/sbin/netplan apply
	fi
    fi
    if ( [ "${BUILDOS}" = "debian" ] )
    then
        if ( [ "${BUILDOSVERSION}" = "10" ] )
            then
	    IP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYIP'`"
            /bin/sed -i "s/address.*/address ${IP}/" /etc/network/interfaces
            /sbin/ifup ens7
        fi
	if ( [ "${BUILDOSVERSION}" = "11" ] )
            then
	    IP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYIP'`"
            /bin/sed -i "s/address.*/address ${IP}/" /etc/network/interfaces
            /sbin/ifup enp6s0
        fi
    fi
fi

