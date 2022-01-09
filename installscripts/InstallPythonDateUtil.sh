#!/bin/sh
###################################################################################
# Description: This  will install python date util
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
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y -f install python3-dateutil
    /usr/bin/pip install python-dateutil
    /bin/rm /usr/bin/python
    /usr/bin/ln /usr/bin/python3 /usr/bin/python
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y -f install python-dateutil
    /usr/bin/pip install python-dateutil
    /bin/rm /usr/bin/python
    /usr/bin/ln /usr/bin/python3 /usr/bin/python
fi

