#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which creates a repository
#############################################################################################
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

if ( [ "${provider_name}" = "bitbucket" ] )
then
    /usr/bin/curl -X POST -v -u ${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD} -H "Content-Type: application/json" https://api.bitbucket.org/2.0/repositories/${REPOSITORY_USERNAME}/${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER} -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'
fi
if ( [ "${provider_name}" = "github" ] )
then
    repo_name="${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}"
    /usr/bin/curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" https://api.github.com/user/repos -d '{"name":"'$repo_name'","private":"true"}'
fi
if ( [ "${provider_name}" = "gitlab" ] )
then
    APPLICATION_REPOSITORY_TOKEN="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYTOKEN:* | /usr/bin/awk -F':' '{print $NF}'`"
    repo_name="${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}"
    /usr/bin/curl --header "PRIVATE-TOKEN: ${APPLICATION_REPOSITORY_TOKEN}" -F "name=${repo_name}" https://gitlab.com/api/v3/projects
fi
