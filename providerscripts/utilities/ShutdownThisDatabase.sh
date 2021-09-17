#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date   : 10/07/2016
# Description : Cleanup and then shutdown this database instance.
########################################################################################
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
########################################################################################
########################################################################################
#set -x

/bin/echo ""
/bin/echo "#######################################################################"
/bin/echo "Shutting down a database, please wait whilst I clean the place up first"

if ( [ "$1" = "backup" ] )
then
    /bin/echo "Making an daily and shutdown backup of your database"
    BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
    ${HOME}/providerscripts/git/Backup.sh "DAILY" ${BUILD_IDENTIFIER} > /dev/null 2>&1
    ${HOME}/providerscripts/git/Backup.sh "SHUTDOWN" ${BUILD_IDENTIFIER} > /dev/null 2>&1
fi

/bin/echo "#######################################################################"
/bin/echo ""

if ( [ -f ${HOME}/config/databaseip/`${HOME}/providerscripts/utilities/GetIP.sh` ] )
then
    /bin/rm ${HOME}/config/databaseip/`${HOME}/providerscripts/utilities/GetIP.sh`
fi

${HOME}/providerscripts/email/SendEmail.sh "A database is being shutdown" "A database is being shutdown"

/usr/sbin/shutdown -h now
