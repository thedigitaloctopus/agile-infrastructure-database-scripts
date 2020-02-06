#!/bin/sh
########################################################################################
# Description: Place the scripts which customise your application here. Select based on
# APPLICATIONIDENTIFIER for the application type you are customising for
# Date: 18/11/2016
# Author: Peter Winter
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
######################################################################################
######################################################################################
#set -x
if ( [ -f ${HOME}/.ssh/APPLICATIONIDENTIFIER:1 ] )
then
    #Application specific customisations for the socialnetwork application -APPLICATIONIDENTIFIER=1
    /bin/echo "*/2 * * * * export HOME=${HOMEDIR} && ${HOME}/applicationscripts/socialnetwork/EmailStatusUpdates.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "0 0 * * 6 export HOME=${HOMEDIR} && ${HOME}/applicationscripts/socialnetwork/EmailWeeklyReports.sh" >> /var/spool/cron/crontabs/root
fi
