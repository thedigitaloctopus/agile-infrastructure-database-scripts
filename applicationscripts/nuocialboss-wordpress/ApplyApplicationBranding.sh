#!/bin/sh
########################################################################################################
# Description: This will apply application branding to the database data
# Author: Peter Winter
# Date: 17/05/2017
########################################################################################################
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

if ( [ "`/bin/ls ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql`" != "" ] )
then

    domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
    /bin/sed -i "s/ApplicationDomainSpec/${domainspecifier}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql

    /bin/sed -i "s/@${WEBSITE_URL}/@${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/https:\/\/mail.${WEBSITE_URL}/https:\/\/mail.${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/mail.${WEBSITE_URL}/@${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/@mail.${ROOT_DOMAIN}/@${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql

    /bin/sed -i "s/www.applicationdomain.tld/${WEBSITE_URL}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/@applicationdomain.tld/@${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/applicationdomain.tld/${WEBSITE_URL}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/The GreatApplication/${WEBSITE_DISPLAY_NAME}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/GreatApplication/${WEBSITE_DISPLAY_NAME}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/THE GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    FROM_EMAIL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILUSERNAME'`"
    /bin/sed -i "s/XXX@YYY/${FROM_EMAIL}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/XXXXXXXXXX/${DB_U}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    IPMASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
    /bin/sed -i "s/YYYYYYYYYY/${IPMASK}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/THE THE/THE/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/The The/The/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    /bin/sed -i "s/@${WEBSITE_URL}/@${ROOT_DOMAIN}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
fi
