#!/bin/sh

version="`/usr/bin/curl https://github.com/git-lfs/git-lfs/ | /bin/grep -ow "v[0-9].*\.[0-9].*\.[0-9].*" | /bin/sed 's/<.*//g' | /usr/bin/tail -1`"
/usr/bin/wget https://github.com/git-lfs/git-lfs/releases/download/${version}/git-lfs-linux-amd64-${version}.tar.gz
/bin/mkdir git-lfs
/bin/tar xvfz git-lfs-linux-amd64-${version}.tar.gz -C ./git-lfs
/bin/bash ./git-lfs/install.sh
/bin/rm -r git-lfs
