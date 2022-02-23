#!/bin/sh
###################################################################################
# Description: Setup the shared config directory
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

if ( [ "`/bin/ls ${HOME}/config 2>&1 | /bin/grep "Transport endpoint is not connected"`" != "" ] )
then
    /bin/umount -f ${HOME}/config
fi

# I found that S3FS has memory creep meaning that it slowly uses up more and more memory to deal with this in as least hacky was as possible
# I check when S3FS is using more than 15% memory and unmount it and remounting it straight away. This will release the memory it was using
# until the next time its at 15% when this process will be repeated again

if ( [ "`/usr/bin/ps aux --sort=-%mem | /usr/bin/head | /bin/grep s3fs | /bin/grep config$ | /usr/bin/awk '{print $4}' | /usr/bin/xargs -n1 printf \"%1.f\n\"`" -eq "15" ] )
then
    /bin/sleep `/usr/bin/shuf -i 1-60 -n 1`
    /bin/umount -f ${HOME}/config
fi

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" != "" ] )
then
    if ( [ ! -f ${HOME}/config/${SERVER_USER} ] || [ ! -f ${HOME}/runtime/CONFIG-PRIMED ] )
    then
     #   /bin/rm -r ${HOME}/config/*
     #   /bin/sleep 5
        /bin/touch ${HOME}/config/${SERVER_USER}
        /bin/touch ${HOME}/runtime/CONFIG-PRIMED
    fi
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" != "" ] &&  [ "`/bin/ls ${HOME}/config/${SERVER_USER}`" != "" ] )
then
    exit
fi


BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"
endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

if ( [ "${DATASTORE_CHOICE}" = "amazonS3" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
       if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
       then
           aws_region="`/bin/grep region ${HOME}/.aws/config | /usr/bin/awk '{print $NF}'`"
           /bin/mkdir ~/.aws 2>/dev/null
           /bin/cp ${HOME}/.aws/* ~/.aws 2>/dev/null

           /usr/bin/aws efs describe-file-systems | /usr/bin/jq '.FileSystems[] | .CreationToken + " " + .FileSystemId' | /bin/sed 's/\"//g' | while read identifier
           do
                if ( [ "`/bin/echo ${identifier} | /bin/grep ${configbucket}`" != "" ] )
                then
                    id="`/bin/echo ${identifier} | /usr/bin/awk '{print $NF}'`"
                    efsmounttarget="`/usr/bin/aws efs describe-mount-targets --file-system-id ${id} | /usr/bin/jq '.MountTargets[].IpAddress' | /bin/sed 's/"//g'`"
                    /bin/mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efsmounttarget}:/   ${HOME}/config
                 fi
            done
        else
            /usr/bin/s3cmd mb s3://${configbucket}
            /usr/bin/s3fs -o nonempty,allow_other,use_path_request_style,sigv2,max_stat_cache_size=10000,stat_cache_expire=30,multireq_max=50 -ourl=https://${endpoint} ${configbucket} ${HOME}/config
        fi
    fi
fi

if ( [ "${DATASTORE_CHOICE}" = "digitalocean" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg  | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    /usr/bin/s3fs -o nonempty,allow_other,use_path_request_style,sigv2,max_stat_cache_size=10000,stat_cache_expire=30,multireq_max=50 -ourl=https://${endpoint} ${configbucket} ${HOME}/config
fi

if ( [ "${DATASTORE_CHOICE}" = "exoscale" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    /usr/bin/s3fs -o nonempty,allow_other,use_path_request_style,sigv2,max_stat_cache_size=10000,stat_cache_expire=30,multireq_max=50 -ourl=https://${endpoint} ${configbucket} ${HOME}/config
fi

if ( [ "${DATASTORE_CHOICE}" = "linode" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    /usr/bin/s3fs -o nonempty,allow_other,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=30,multireq_max=50 -ourl=https://${endpoint} ${configbucket} ${HOME}/config
fi

if ( [ "${DATASTORE_CHOICE}" = "vultr" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    /usr/bin/s3fs -o nonempty,allow_other,use_path_request_style,sigv2,max_stat_cache_size=10000,stat_cache_expire=30,multireq_max=50 -ourl=https://${endpoint} ${configbucket} ${HOME}/config
fi

${HOME}/providerscripts/utilities/SetupConfigDirectories.sh


