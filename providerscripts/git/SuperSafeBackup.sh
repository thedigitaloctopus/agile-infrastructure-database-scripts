#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which can be used to make "super safe" backups
#################################################################################
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
########################################################################################################################
####RUN THIS SCRIPT MANUALLY WHENEVER YOU FEEL YOU WANT TO HAVE A SUPER SAFE BACKUP OF ONE OF A REPOSITORY
####RUN IT ONCE FOR EACH REPOSITORY YOU WISH TO BACKUP PASSING REPOSITORY NAME FROM THE HTTPS URL
####TO THE REPOSITORY YOU WISH TO BACKUP AS A PARAMETER TO THIS SCRIPT
#########################################################################################################################
#set -x

BUIILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

if ( [ "$1" = "" ] )
then
    /bin/echo "Usage ./SuperSafeBackup.sh <datastoreprovider>"
    exit
fi
datastoreprovider="$1"

if ( [ "${datastoreprovider}" = "" ] )
then
    /bin/echo "Please select your datastore provider 1. Amazon S3 2. Digital Ocean 3.Exoscale"
    read choice

    if ( [ "`/bin/echo 1 2 3 | grep ${choice}`" = "" ] )
    then
        /bin/echo "Invalid datastore provider, please try again...."
        read choice
    fi

    if ( [ "${choice}" = "1" ] )
    then
        datastoreprovider="amazons3"
elif ( [ "${choice}" = "2" ] )
    then
        datastoreprovider="digitalocean"
elif ( [ "${choice}" = "3" ] )
    then
        datastoreprovider="exoscale"
    fi
fi

BUILD_HOME="/root"
if ( [ ! -d ${HOME}/supersafebackup ] )
then
    /bin/mkdir ${HOME}/supersafebackup
fi

cd ${HOME}/supersafebackup

/bin/rm -r ${HOME}/supersafebackup/* 2>/dev/null
/bin/cp -r ${HOME}/backups/* ${HOME}/supersafebackup

if ( [ "`/usr/bin/dpkg -l git | /bin/grep 'no package'`" != "" ] )
then
    /bin/echo "It looks like you don't have git installed on your machine. Can we install it"
    /bin/echo "Enter (Y/N)"
    read answer
if ( "`/bin/echo ${answer} | /bin/grep 'Y'`" != "" ] )
    then
        /usr/bin/add-apt-repository -y ppa:git-core/ppa
	${HOME}/installscripts/Update.sh ${BUILDOS}
	${HOME}/installscripts/InstallGit.sh ${BUILDOS}
    fi
fi

if ( [ "${datastoreprovider}" = "amazons3" ] || [ "${datastore_provider}" = "digitalocean" ]  )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
       # /usr/bin/apt-get install -qq s3cmd
       ${HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD'
    fi
    if ( [ ! -f ~/.s3cfg ] )
    then
        /bin/echo "You need to configure your datastore tools. You can get your access keys by going to your AWS account at aws.amazon.com and following the instructions"
        /usr/bin/s3cmd --configure
    fi
fi

cd ${HOME}/supersafebackup

date="`/bin/date | /bin/sed 's/ //g' | /bin/sed 's/://g'`"
BUCKET_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'${date} | /bin/sed 's/\./-/g'`"


if ( [ "${datastoreprovider}" = "amazons3" ] || [ "${datastore_provider}" = "digitalocean" ] )
then
    /usr/bin/s3cmd mb s3://${BUCKET_NAME}
    /usr/bin/s3cmd put --multipart-chunk-size-mb=5 --recursive ${HOME}/supersafebackup/* s3://${BUCKET_NAME}
fi
/bin/rm -r ${HOME}/supersafebackup/*
