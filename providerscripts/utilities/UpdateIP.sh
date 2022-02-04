#!/bin/sh
##################################################################################################
# Author : Peter Winter
# Date   : 10/4/2016
# Description : This script updates the DB IP address
##################################################################################################
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
##########################################################################################
##########################################################################################
#set -x

if ( [ ! -d ${HOME}/config/databaseip ] )
then
    /bin/mkdir ${HOME}/config/databaseip
fi

localip="`${HOME}/providerscripts/utilities/GetIP.sh`"
/bin/touch /tmp/${localip}
/bin/cp /tmp/${localip} ${HOME}/config/databaseip/${localip}

for ip in "`/bin/ls ${HOME}/config/databaseip`"
do
    if ( [ "`/bin/echo ${ip}`" != "${localip}" ] )
    then
        /bin/rm ${HOME}/config/databaseip/${ip}
    fi
done

if ( [ ! -d ${HOME}/config/databasepublicip ] )
then
    /bin/mkdir ${HOME}/config/databasepublicip
fi

publicip="`${HOME}/providerscripts/utilities/GetPublicIP.sh`"
/bin/touch /tmp/${publicip}
/bin/cp /tmp/${publicip} ${HOME}/config/databasepublicip/${publicip}

for ip in "`/bin/ls ${HOME}/config/databasepublicip`"
do
    if ( [ "`/bin/echo ${ip}`" != "${publicip}" ] )
    then
        /bin/rm ${HOME}/config/databasepublicip/${ip}
    fi
done
