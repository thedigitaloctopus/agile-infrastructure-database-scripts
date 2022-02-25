#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will install postgres from source
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
export HOME=`/bin/cat /home/homedir.dat`
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

#Install needed libraries
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y build-essential 
    /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y curl
    /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y zlib1g-dev
    /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y flex
    /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -qq -y bison
fi

version="`/usr/bin/curl https://www.postgresql.org/ftp/source/ | /bin/grep -o ">v.*<\/a" | /bin/sed 's/^>//g' | /bin/sed 's/<.*//g' | /bin/grep -v "alpha" | /bin/grep -v "beta" | /usr/bin/head -1 | /bin/sed 's/v//g'`"

if ( [ ! -f postgresql-${version}.tar.gz ] )
then
    /usr/bin/wget https://ftp.postgresql.org/pub/source/v${version}/postgresql-${version}.tar.gz
fi

/bin/tar xvfz postgresql-${version}.tar.gz
/bin/rm postgresql-${version}.tar.gz
cd postgresql-${version}
./configure --without-readline
/usr/bin/make
/usr/bin/make install
/usr/sbin/useradd postgres
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
/usr/sbin/usermod --password ${DB_P} postgres
/bin/mkdir /home/postgres
/bin/chown postgres.postgres /home/postgres
/usr/bin/mkdir /usr/local/pgsql/data
/usr/bin/chown postgres:postgres /usr/local/pgsql/data
/usr/sbin/runuser -l "postgres" -c "/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data/"
/usr/sbin/runuser -l "postgres" -c "/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start"

/bin/echo "#!/bin/bash

/usr/sbin/runuser -l \"postgres\" -c \"/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start\"

/bin/sleep 10

postgreses=\"\`/usr/bin/ps -ef | /bin/grep postgres | /bin/grep -v grep | /usr/bin/wc -l\`\"

while ( [ \"\${postgreses}\" = \"0\" ] )
do
    /usr/sbin/runuser -l \"postgres\" -c \"/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start\"
    postgreses=\"\`/usr/bin/ps -ef | /bin/grep postgres | /bin/grep -v grep | /usr/bin/wc -l\`\"
    /bin/sleep 10
done

exit 0" > /etc/rc.local

/bin/chmod +x /etc/rc.local

/bin/echo "[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
 
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/rc-local.service

/usr/bin/systemctl enable rc-local.service
/usr/bin/systemctl start rc-local.service

if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    /bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
    ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -y install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
    /usr/bin/ln -s /usr/local/pgsql/bin/psql /usr/bin/psql
fi

/bin/touch ${HOME}/runtime/POSTGRES_FROM_SOURCE
