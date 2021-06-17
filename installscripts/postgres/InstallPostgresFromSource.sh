/usr/bin/apt install -qq -y software-properties-common
/usr/bin/apt install -qq -y build-essential 
/usr/bin/apt install -qq -y curl
/usr/bin/apt install -qq -y zlib1g-dev


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
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
/usr/sbin/usermod --password ${DB_P} postgres
/bin/mkdir /home/postgres
/bin/chown postgres.postgres /home/postgres
/usr/bin/mkdir /usr/local/pgsql/data
/usr/bin/chown postgres:postgres /usr/local/pgsql/data
/usr/sbin/runuser -l "postgres" -c "/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data/"
/usr/sbin/runuser -l "postgres" -c "/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start"

/bin/echo "#!/bin/bash

/usr/sbin/runuser -l \"postgres\" -c \"/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start\"

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

/usr/bin/wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
/bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
/usr/bin/apt update
/usr/bin/apt -y install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
/bin/touch ${HOME}/runtime/POSTGRES_FROM_SOURCE
