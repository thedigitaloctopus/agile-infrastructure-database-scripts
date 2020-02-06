#!/bin/sh
######################################################################################
# Description: This script will delete all the files in a repository, but will not actually
# delete the repository itself.
# Author: Peter Winter
# Date: 11/01/2017
#####################################################################################
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

REPOSITORY_USERNAME="${1}"
REPOSITORY_PASSWORD="${2}"
WEBSITE_NAME="${3}"
period="${4}"
BUILD_IDENTIFIER="${5}"
provider_name="${6}"

REPOSITORY_NAME="${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}"
REPOSITORY_PROVIDER="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYPROVIDER:* | /usr/bin/awk -F':' '{print $NF}'`"
REPOSITORY_OWNER="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYOWNER:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${provider_name}" = "bitbucket" ] )
then
    /usr/bin/curl -X DELETE --user ${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD} https://api.bitbucket.org/2.0/repositories/${REPOSITORY_OWNER}/${REPOSITORY_NAME}
fi
if ( [ "${provider_name}" = "github" ] )
then
    /usr/bin/curl -X DELETE -u ${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD} https://api.github.com/repos/${REPOSITORY_OWNER}/${REPOSITORY_NAME}
fi
if ( [ "${provider_name}" = "gitlab" ] )
then
    APPLICATION_REPOSITORY_TOKEN="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYTOKEN:* | /usr/bin/awk -F':' '{print $NF}'`"
    /usr/bin/curl --request DELETE --header "PRIVATE-TOKEN: ${APPLICATION_REPOSITORY_TOKEN}" https://gitlab.com/api/v3/projects/${REPOSITORY_OWNER}%2F${REPOSITORY_NAME}
fi


