#!/bin/sh
##################################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script is an application specific script which is used for making status updates
###################################################################################################
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

#Retrieve the current batch of status update messages
${HOME}/applicationscripts/socialnetwork/GetStatusUpdates.sh

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

while read message
do
    /bin/echo "${0} `/bin/date` : Sending a status update email for message: ${message}" >> ${HOME}/logs/MonitoringLog.dat

    #Get the email addresses of members that need to recieve the notification

    ref_id="`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e "select user_id from uq893_comprofiler_plugin_activity where message='${message}';"`"

    /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e "SELECT a.memberid FROM uq893_comprofiler_members AS a LEFT JOIN uq893_comprofiler AS b ON a.memberid=b.user_id WHERE a.referenceid='${ref_id}' AND a.accepted=1 AND a.pending=0;"  > /tmp/emailids.dat


    while read emailid
    do
        /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e  "select email from uq893_users where id='"${emailid}"';"
    done < /tmp/emailids.dat > /tmp/emailaddresses.dat

    /bin/echo "${0} `/bin/date` : Got email addresses to send the notification to" >> ${HOME}/logs/MonitoringLog.dat

    #For each email adress that needs to be notified, send them the message

    while read emailaddress
    do
        name="`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e  "select name from uq893_users where id='"${ref_id}"';"`"
        emailid="`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e  "select id from uq893_users where email='"${emailaddress}"';"`"
        notifications="`/usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} -N -e "select cb_statusnotifications from uq893_comprofiler where id='"${emailid}"';"`"

        #The user can override notification from their profile. If notifications are switched on, then send the email, otherwise don't send it
        if ( [ "${notifications}" = "1" ] )
        then
            ${HOME}/SendEmail.sh "STATUS UPDATE NOTIFICATION :" "STATUS UPDATE FROM ${name} `/bin/date`
 #############################################################################\n
$message\n
#############################################################################\n
            Note: You can disable notifications from your profile"  ${emailaddress}
            /bin/echo "${0} `/bin/date` : Sent the notification email" >> ${HOME}/logs/MonitoringLog.dat
        fi
    done < /tmp/emailaddresses.dat
done < ${HOME}/status/messages.dat

#Cleanup

/bin/rm ${HOME}/status/*
