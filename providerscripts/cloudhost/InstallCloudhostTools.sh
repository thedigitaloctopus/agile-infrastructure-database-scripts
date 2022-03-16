 #!/bin/sh
##############################################################################
# Description: This script will install the tools for the selected cloudhost.
# It is with these tools that servers can be manipulated.
# Author: Peter Winter
# Date: 12/01/2017
##############################################################################
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
#############################################################################
#############################################################################

#Configure the machine for the current provider. Each new provider that is added will need a config process like these to be added
#here. Note, only AWS actually requires the cloudhost tools to be installed on the database machine which is why the cloudhost tools
#are not installed for the other providers

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /usr/bin/touch ${HOME}/EXOSCALE
fi

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    /usr/bin/touch ${HOME}/DROPLET
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    /usr/bin/touch ${HOME}/LINODE
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    /usr/bin/touch ${HOME}/VULTR
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    ${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
    ${HOME}/installscripts/InstallAWSCLI.sh ${BUILDOS}
    /usr/bin/touch ${HOME}/AWS
fi
