#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script will build a database server
#################################################################################################################
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

#If there is a problem with building a database, you can uncomment the set -x command and debug output will be
#presented on the screen as your database is built


USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
export HOME="/home/${USER_HOME}" | /usr/bin/tee -a ~/.bashrc
export HOMEDIR=${HOME}
/bin/echo "${HOMEDIR}" > /home/homedir.dat

#First thing is to tighten up permissions in case theres any wronguns. 

/bin/chmod -R 750 ${HOME}/cron ${HOME}/installscripts ${HOME}/providerscripts ${HOME}/security

if ( [ ! -d ${HOME}/logs ] )
then
    /bin/mkdir ${HOME}/logs
fi

OUT_FILE="database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${OUT_FILE}
ERR_FILE="database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${ERR_FILE}

#Validate the parameters that have been passed
if ( [ "$1" = "" ] || [ "$2" = "" ] )
then
    /bin/echo "Usage: ./db.sh <build archive choice> <server_user>" >> ${HOME}/logs/DATABASE_BUILD.dat
    exit
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Building a new database server" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Load the configuration into memory for easy access
BUILD_ARCHIVE_CHOICE="$1"
SERVER_USER="$2"
BUILD_TYPE="$3"


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Settting up build parameters" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

${HOME}/providerscripts/utilities/StoreConfigValue.sh "BUILDARCHIVECHOICE" "${BUILD_ARCHIVE_CHOICE}"

CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"
AUTOSCALERIP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ASIP'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
ALGORITHM="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ALGORITHM'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
DATABASE_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"
GIT_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSHPORT'`"

#Non standard variable settings
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"

#Record what everything has actually been set to in case there is a problem...
/bin/echo "CLOUDHOST:${CLOUDHOST}" > ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "AUTOSCALERIP:${AUTOSCALERIP}" > ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BUILD_IDENTIFIER:${BUILD_IDENTIFIER}" > ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "ALGORITHM:${ALGORITHM}" > ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_URL:${WEBSITE_URL}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_DISPLAY_NAME:${WEBSITE_DISPLAY_NAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BASELINE_DB_REPOSITORY_NAME:${BASELINE_DB_REPOSITORY_NAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PROVIDER:${INFRASTRUCTURE_REPOSITORY_PROVIDER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_USERNAME:${INFRASTRUCTURE_REPOSITORY_USERNAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PASSWORD:${INFRASTRUCTURE_REPOSITORY_PASSWORD}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_OWNER:${INFRASTRUCTURE_REPOSITORY_OWNER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_PROVIDER:${INFRASTRUCTURE_REPOSITORY_PROVIDER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_USERNAME:${INFRASTRUCTURE_REPOSITORY_USERNAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_PASSWORD:${INFRASTRUCTURE_REPOSITORY_PASSWORD}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_OWNER:${INFRASTRUCTURE_REPOSITORY_OWNER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "DATABASE_INSTALLATION_TYPE:${DATABASE_INSTALLATION_TYPE}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "GIT_USER:${GIT_USER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "GIT_EMAIL_ADDRESS:${GIT_EMAIL_ADDRESS}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SERVER_TIMEZONE_CONTINENT:${SERVER_TIMEZONE_CONTINENT}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SERVER_TIMEZONE_CITY:${SERVER_TIMEZONE_CITY}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SSH_PORT:${SSH_PORT}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_NAME:${WEBSITE_NAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "ROOT_DOMAIN:${ROOT_DOMAIN}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BUILDOS:${BUILDOS}" >> ${HOME}/logs/InitialBuildEnvironment.log

#Setup the directory structure

if ( [ ! -d ${HOME}/.ssh ] )
then
    /bin/mkdir ${HOME}/.ssh
fi
if ( [ ! -d ${HOME}/config ] )
then
    /bin/mkdir ${HOME}/config
fi
if ( [ ! -d ${HOME}/providerscripts ] )
then
    /bin/mkdir ${HOME}/providerscripts
fi
if ( [ ! -d ${HOME}/applicationscripts ] )
then
    /bin/mkdir ${HOME}/applicationscripts
fi

if ( [ ! -d ${HOME}/runtime ] )
then
    /bin/mkdir ${HOME}/runtime
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Setting hostname to: ${WEBSITE_NAME}DB" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
#Set the hostname for the machine
/bin/echo "${WEBSITE_NAME}DB" > /etc/hostname
/bin/hostname -F /etc/hostname

if ( [ "${BUILDOS}" = "debian" ] )
then
    /bin/sed -i "/127.0.0.1/ s/$/ ${WEBSITE_NAME}DB/" /etc/cloud/templates/hosts.debian.tmpl
    /bin/sed -i '1 i\127.0.0.1        localhost' /etc/cloud/templates/hosts.debian.tmpl

    if ( [ "`/bin/cat /etc/hosts | /bin/grep 127.0.1.1 | /bin/grep "${WEBSITE_NAME}"`" = "" ] )
    then
        /bin/sed -i "s/127.0.1.1/127.0.1.1 ${WEBSITE_NAME}DBX/g" /etc/hosts
        /bin/sed -i "s/X.*//" /etc/hosts
    fi
    /bin/sed -i "0,/127.0.0.1/s/127.0.0.1/127.0.0.1 ${WEBSITE_NAME}DB/" /etc/hosts
else
    /usr/bin/hostnamectl set-hostname ${WEBSITE_NAME}DB
fi

#Precautions against kernel panics
/bin/echo "vm.panic_on_oom=1
kernel.panic=10" >> /etc/sysctl.conf


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Installing necessary software" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
#Update and upgrade the software to its latest available versions

${HOME}/installscripts/Update.sh ${BUILDOS}
${HOME}/installscripts/Upgrade.sh ${BUILDOS}
${HOME}/installscripts/InstallSoftwareProperties.sh ${BUILDOS}
${HOME}/installscripts/InstallGitLFS.sh ${BUILDOS}
${HOME}/installscripts/InstallCurl.sh ${BUILDOS}
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS}
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS}
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
${HOME}/installscripts/InstallUFW.sh ${BUILDOS}
${HOME}/installscripts/InstallSSHFS.sh ${BUILDOS}
${HOME}/installscripts/InstallS3FS.sh ${BUILDOS}
${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
${HOME}/installscripts/InstallJQ.sh ${BUILDOS}

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
then
    ${HOME}/installscripts/InstallNFS.sh ${BUILDOS}
fi

${HOME}/providerscripts/utilities/InstallMonitoringGear.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Setting timezone" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
#Set the time on the machine
/usr/bin/timedatectl set-timezone ${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}
${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECONTINENT" "${SERVER_TIMEZONE_CONTINENT}"
${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECITY" "${SERVER_TIMEZONE_CITY}"
export TZ=":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}"

#Some rudimentary checks to ensure that the software is installed
if ( [ -f /usr/bin/sendemail ] && [ -f /usr/bin/curl ] && [ -f /usr/bin/sshfs ] )
then
    /bin/echo "${0} `/bin/date` : It looks like all the required software was installed correctly" >> ${HOME}/logs/MonitoringLog.dat
else
    /bin/echo "${0} `/bin/date` : It looks like all the required software wasn't installed correctly" >> ${HOME}/logs/MonitoringLog.dat
    exit
fi

/bin/mkdir -p ${HOME}/credentials
/bin/chmod 700 ${HOME}/credentials


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Installing Cloudhost tools" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Install the tools for our particular cloudhost provider
. ${HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Getting infrastructure repositories from git" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Configure git
cd ${HOME}
/usr/bin/git init >/dev/null
/bin/echo "${0} `/bin/date`: Installing GIT ...." >> ${HOME}/logs/MonitoringLog.dat
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch master
/usr/bin/git config --global pull.rebase false 


/bin/echo "${0} `/bin/date`: Pulling configuration scripts from repository" >> ${HOME}/logs/MonitoringLog.dat

#Install the infrastructure scripts on the machine
${HOME}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER}  agile-infrastructure-database-scripts  > /dev/null 2>&1

#Set permissions appropriately
/usr/bin/find ${HOME} -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -type f -print0 | xargs -0 chmod 0500 # for files


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Setting up script that allows us to root" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

/bin/mv ${HOME}/providerscripts/utilities/Super.sh ${HOME}/.ssh
/bin/chmod 400 ${HOME}/.ssh/Super.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Setting up datastore tools" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

. ${HOME}/providerscripts/datastore/InstallDatastoreTools.sh

cd ${HOME}

#If we are using an SSH tunnel, then we need to set it up here so that when we are installing the application
#there is a tunnel for us to communicate through to get the the datbase running as a remote service.
#The SSH tunnel will be setup automatically every time this machine is rebooted
#When the application is running, it communicates with the remote DB running as a service using its own SSH tunnel
#In this case, the database server we are building here has no operational use, but, it does have the workflow
#to install the application into the remote database and also to make periodic backups of the database and that
#is why we have to build it. In ordinary operation of the application, this machine is not touched the webserver
#communicates directly to the database running as a remote service.
#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS-secured`" = "1" ] )
#then
#    ${HOME}/providerscripts/utilities/SetupSSHTunnel.sh
#fi

#Stop cron from sending notification emails
/bin/echo "MAILTO=''" > /var/spool/cron/crontabs/root


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Installing the application DB" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
#Initialise the database
. ${HOME}/providerscripts/database/singledb/InstallSingleDB.sh ${DATABASE_INSTALLATION_TYPE}

BYPASS_DB_LAYER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

if ( [ "${BYPASS_DB_LAYER}" != "1" ] )
then
    #...and install the application
    if ( [ "${BASELINE_DB_REPOSITORY_NAME}" != "VIRGIN" ] )
    then
        export HOME=${HOMEDIR} && . ${HOME}/applicationdb/InstallApplicationDB.sh
        #Perform any application specific customisations
        . ${HOME}/applicationscripts/CustomiseApplication.sh
    fi
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Configuring our SSH settings" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Set the ssh port we want to use
#/bin/sed -i "s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
#/bin/sed -i 's/^#Port/Port/' /etc/ssh/sshd_config


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Disabling password authentication" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

/bin/sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
/bin/sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Changing to our preferred SSH port" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

if ( [ "`/bin/grep '^#Port' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^Port' /etc/ssh/sshd_config`" != "" ] )
then
    /bin/sed -i "s/^Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
    /bin/sed -i "s/^#Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
else
    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Preventing root logins" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

if ( [ "`/bin/grep '^#PermitRootLogin' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^PermitRootLogin' /etc/ssh/sshd_config`" != "" ] )
then
    /bin/sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    /bin/sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
else
    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Ensuring SSH connections are long lasting" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

#Make sure that client connections to sshd are long lasting
if ( [ "`/bin/grep 'ClientAliveInterval 200' /etc/ssh/sshd_config 2>/dev/null`" = "" ] )
then
    /bin/echo "
ClientAliveInterval 200
    ClientAliveCountMax 10" >> /etc/ssh/sshd_config
fi

/usr/sbin/service sshd restart

#Set userallow for fuse
/bin/sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Initialising cron" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
# Configure the crontab
. ${HOME}/providerscripts/utilities/InitialiseCron.sh

#This call is necessary as it primes the networking interface for some providers.
${HOME}/providerscripts/utilities/GetIP.sh

#${HOME}/installscripts/Upgrade.sh ${BUILDOS}

#do some finalising
/usr/bin/touch ${HOME}/runtime/DATABASE_READY
/bin/echo "${0} `/bin/date`: Rebooting down after build" >> ${HOME}/logs/MonitoringLog.dat
/bin/rm -r ${HOME}/bootstrap
/bin/chown -R ${SERVER_USER}.${SERVER_USER} ${HOME}
/bin/sed -i "s/IPV6=yes/IPV6=no/g" /etc/default/ufw


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Setting up firewall" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log


/usr/sbin/ufw logging off
#The firewall is down until the initial configuration steps are completed. We set our restrictive rules as soon as possible
#and pull our knickers up fully after 10 minutes with a call from cron
/usr/sbin/ufw default allow incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw --force enable

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} `/bin/date`: Rebooting after install" >> ${HOME}/logs/DATABASE_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/DATABASE_BUILD.log

${HOME}/providerscripts/email/SendEmail.sh "A DATABASE HAS BEEN SUCCESSFULLY BUILT" "A Database has been successfully built and primed as is rebooting ready for use"

/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK

#Make sure everything is intialised by rebooting the machine
/sbin/shutdown -r now
