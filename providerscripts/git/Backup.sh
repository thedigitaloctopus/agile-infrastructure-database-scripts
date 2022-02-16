#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which backups up the application  DB to
# the application git repository provider along with to the datastore if supersafe
# backups are enabled. 
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
##################################################################################
##################################################################################
#set -x

if ( [ "$1" = "" ] || [ "$2" = "" ] )
then
    /bin/echo "This script requires the <Build periodicity> and the <build identifier> parameters to be set"
    exit
fi

if ( ( [ "`/bin/mount | /bin/grep home | /bin/grep config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] ) || [ ! -f ${HOME}/config/INSTALLEDSUCCESSFULLY ] )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

#Non standard variables
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"


if ( [ ! -d ${HOME}/backups ] )
then
    /bin/mkdir -p ${HOME}/backups
fi

/bin/rm -r ${HOME}/backups/*

APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"

BUILD_IDENTIFIER="$2"

if ( [ "$1" = "HOURLY" ] )
then
    period="hourly"
fi
if ( [ "$1" = "DAILY" ] )
then
    period="daily"
fi
if ( [ "$1" = "WEEKLY" ] )
then
    period="weekly"
fi
if ( [ "$1" = "MONTHLY" ] )
then
    period="monthly"
fi
if ( [ "$1" = "BIMONTHLY" ] )
then
    period="bimonthly"
fi
if ( [ "$1" = "SHUTDOWN" ] )
then
   period="shutdown"
fi
if ( [ "$1" = "MANUAL" ] )
then
   period="manual"
fi


#Get the date as a unique timestamp for the backup

date="`/bin/date | /bin/sed 's/ //g'`"
/bin/echo "${0} `/bin/date`: Backing up database" >> ${HOME}/logs/MonitoringLog.dat
websiteDB="${HOME}/backups/${WEBSITE_NAME}-DB-backup".tar.gz

DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"

cd ${HOME}/backups

. ${HOME}/providerscripts/git/utilities/BackupDatabase.sh

cd ${HOME}/backups

count=0

if ( [ -d ${HOME}/backups/.git ] )
then
    /bin/rm -r ${HOME}/backups/.git
fi

/bin/rm ${HOME}/backups/${period}/*
/bin/rm -r ${HOME}/.git

if ( [ "${period}" = "hourly" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DISABLEHOURLY:1`" = "1" ] )
then
    /bin/echo "${0} `/bin/date`: Skipping repository creation because hourly backups are disabled" >> ${HOME}/logs/MonitoringLog.dat
elif ( [ "${period}" = "manual" ] )
then
    if ( [ ! -d /tmp/backup_archive ] )
    then
        /bin/mkdir /tmp/backup_archive
    fi
    /bin/rm -r /tmp/backup_archive/*
    /bin/cp ${websiteDB} /tmp/backup_archive/${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}.tar.gz
else
    ${HOME}/providerscripts/git/DeleteRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
    ${HOME}/providerscripts/git/CreateRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
fi

/bin/sleep 30

#Create an archive of the master db
/usr/bin/split -b 10M -d ${websiteDB} "${WEBSITE_NAME}-db-"


if ( [ -d ${HOME}/backups/.git ] )
then
    /bin/rm -r ${HOME}/backups/.git
fi

cd ${HOME}/backups

/usr/bin/git init
/usr/bin/git lfs install
/usr/bin/git lfs track "*tar*"
/usr/bin/git lfs track "*db*"
/usr/bin/git add .gitattributes

if ( [ ! -d ${HOME}/backups/${period} ] )
then
    /bin/mkdir ${HOME}/backups/${period}
fi

/bin/mv *${WEBSITE_NAME}-db* ${HOME}/backups/${period}

cd ${HOME}/backups/

if ( [ "${period}" = "hourly" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DISABLEHOURLY:1`" = "1" ] )
then
    /bin/echo "${0} `/bin/date`: Skipping hourly backup because hourly backups are disabled" >> ${HOME}/logs/MonitoringLog.dat
else
    /bin/systemd-inhibit --why="Persisting database to git repo" ${HOME}/providerscripts/git/GitPushDB.sh "." "Automated Backup" "${APPLICATION_REPOSITORY_PROVIDER}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}"
fi

SUPERSAFE_DB="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SUPERSAFEDB'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"


if ( [ "${SUPERSAFE_DB}" = "1" ] )
then
    if ( [ "${period}" = "hourly" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DISABLEHOURLY:1`" = "1" ] )
    then
        /bin/echo "${0} `/bin/date`: Skipping hourly backup because hourly backups are disabled" >> ${HOME}/logs/MonitoringLog.dat
    else
        ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
        ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
        ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
        /bin/systemd-inhibit --why="Persisting database to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" "${websiteDB}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
    fi
fi
