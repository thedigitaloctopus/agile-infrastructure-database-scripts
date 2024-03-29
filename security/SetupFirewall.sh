#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : Set up the firewall for the database
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
#####################################################################################
#set -x #THIS MUST NOT BE SWITCHED ON DURING NORMAL USE, SCRIPT BREAK
#####################################################################

if ( [ ! -d ${HOME}/logs/firewall ] )
then
    /bin/mkdir -p ${HOME}/logs/firewall
fi

#This stream redirection is required for correct function, please do not remove
exec >${HOME}/logs/firewall/FIREWALL_CONFIGURATION.log
exec 2>&1

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSHPORT'`"

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"

. ${HOME}/providerscripts/utilities/SetupInfrastructureIPs.sh

if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${BUILD_CLIENT_IP} | /bin/grep ALLOW`" = "" ] )
then
    #/usr/sbin/ufw default deny incoming
  #  /usr/sbin/ufw default allow outgoing
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${BUILD_CLIENT_IP} to any port ${SSH_PORT}
    /bin/sleep 2
fi

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "webserverips/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "webserverpublicips/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "databaseip/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT} 
        /bin/sleep 2
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "databasepublicip/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT} 
        /bin/sleep 2
    fi
done

/bin/sleep 5

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "autoscalerpublicip/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        /bin/sleep 2
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "autoscalerip/*"`
do
    /bin/sleep 2
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${DB_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${DB_PORT}
        /bin/sleep 2
    fi
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        /bin/sleep 2
    fi
done

/usr/sbin/ufw -f enable

