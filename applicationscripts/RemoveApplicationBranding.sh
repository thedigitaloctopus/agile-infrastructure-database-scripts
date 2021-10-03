#!/bin/sh
####################################################################################################
# Description: This will remove any branding to a generic form
# Author : Peter Winter
# Date: 17/05/2017
####################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONIDENTIFIER:1`" = "1" ] )
then
    . ${HOME}/applicationscripts/joomla/RemoveApplicationBranding.sh
fi
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONIDENTIFIER:2`" = "1" ] )
then
    . ${HOME}/applicationscripts/wordpress/RemoveApplicationBranding.sh
fi
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONIDENTIFIER:3`" = "1" ] )
then
    . ${HOME}/applicationscripts/drupal/RemoveApplicationBranding.sh
fi
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONIDENTIFIER:4`" = "1" ] )
then
    . ${HOME}/applicationscripts/moodle/RemoveApplicationBranding.sh
fi
