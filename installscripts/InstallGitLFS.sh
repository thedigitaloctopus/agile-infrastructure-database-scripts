#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will install git LFS
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

version="`/usr/bin/curl https://github.com/git-lfs/git-lfs/ | /bin/grep -ow "v[0-9].*\.[0-9].*\.[0-9].*" | /bin/sed 's/<.*//g' | /usr/bin/tail -1`"
/usr/bin/wget https://github.com/git-lfs/git-lfs/releases/download/${version}/git-lfs-linux-amd64-${version}.tar.gz
/bin/mkdir git-lfs
/bin/tar xvfz git-lfs-linux-amd64-${version}.tar.gz -C ./git-lfs
/bin/bash ./git-lfs/install.sh
/bin/rm -r git-lfs
