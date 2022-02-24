#!/bin/sh
####################################################################################
#Description: This script will setup your crontab for you
# Author: Peter Winter
# Date: 28/01/2017
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
#####################################################################################
#Setup crontab
/bin/echo "${0} `/bin/date`: Configuring crontab" >> ${HOME}/logs/MonitoringLog.dat

#These scripts run every minute
/bin/echo "*/1 * * * * export HOME=${HOMEDIR} && ${HOME}/providerscripts/utilities/PrimeCredentials.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME=${HOMEDIR} && ${HOME}/providerscripts/utilities/EnsureAccessForWebservers.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/chmod 700 ${HOME}/.ssh/*" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /usr/bin/find ${HOME}/runtime -name *lock* -type f -mmin +35 -delete" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/PurgeDodgyMounts.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupConfig.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/ObtainBuildClientIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/database/singledb/ExtractIPMaskAndGrant.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 30 && ${HOME}/providerscripts/utilities/UpdateIP.sh" >> /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "#@monthly export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh 'fromcronreset'" >> /var/spool/cron/crontabs/root
fi

#These scripts run every 5 minutes
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/root

#These scripts run ever 10 minutes
/bin/echo "*/10 * * * * export HOME=${HOMEDIR} && ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root

#The scripts run at set times
BYPASS_DB_LAYER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

#If we are using DBaaS then we don't want to run backups from our regular DB layer. The regular DB layer is still required for config
#reasons, but we don't actully use it, the webservers go straight to the DBaaS provider when they query the database
if ( [ "${BYPASS_DB_LAYER}" != "1" ] )
then
     #Time based backups are not taken for virgin CMS installs. Instead, make a baseline if you want to save a copy of your work and work it out from there once your application is ready

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "0" ] ) 
    then
        /bin/echo "2 * * * * export HOME=${HOMEDIR} && ${HOME}/cron/BackupFromCron.sh 'HOURLY' ${BUILD_IDENTIFIER}" >>/var/spool/cron/crontabs/root
        /bin/echo "8 2 * * * export HOME=${HOMEDIR} && ${HOME}/cron/BackupFromCron.sh 'DAILY' ${BUILD_IDENTIFIER}" >>/var/spool/cron/crontabs/root
        /bin/echo "8 3 * * 7 export HOME=${HOMEDIR} && ${HOME}/cron/BackupFromCron.sh 'WEEKLY' ${BUILD_IDENTIFIER}" >>/var/spool/cron/crontabs/root
        /bin/echo "8 4 1 * * export HOME=${HOMEDIR} && ${HOME}/cron/BackupFromCron.sh 'MONTHLY' ${BUILD_IDENTIFIER}" >>/var/spool/cron/crontabs/root
        /bin/echo "8 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME=${HOMEDIR} && ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY' ${BUILD_IDENTIFIER}" >>/var/spool/cron/crontabs/root
    fi
fi

/bin/echo "@daily export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MonitorFreeDiskSpace.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@daily export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/PerformSoftwareUpdate.sh" >> /var/spool/cron/crontabs/root

SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"

/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/SetHostname.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupConfig.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot /bin/sleep 600 && export HOME="${HOMEDIR}" && ${HOME}/security/KnickersUp.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && /usr/bin/find ${HOME}/runtime -name *lock* -type f -delete" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/GetIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/UpdateInfrastructure.sh" >>/var/spool/cron/crontabs/root

if ( [ -f ${HOME}/runtime/POSTGRES_FROM_SOURCE ] )
then
    /bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/database/singledb/postgres/InitialiseDatabaseConfig.sh" >> /var/spool/cron/crontabs/root
fi



#Reload cron
/usr/bin/crontab /var/spool/cron/crontabs/root
