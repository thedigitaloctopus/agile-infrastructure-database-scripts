# /etc/apt/sources.list
# uncomment deb-src
# run apt update

/usr/bin/apt-get install -qq -y build-essential bison cmake
/usr/bin/apt-get -qq -y build-dep mariadb-server 
/usr/bin/git clone https://github.com/MariaDB/server.git
cd server
mariadb_version="`/usr/bin/wget -qO- https://mariadb.com/kb/en/release-notes/ | /bin/grep "MariaDB" | /bin/grep "Release Notes" | /usr/bin/head -n 1 | /bin/sed 's/.*MariaDB //g' | /usr/bin/awk -F' ' '{print $1}'`"
/usr/bin/git checkout ${mariadb_version}
/usr/bin/cmake . -DBUILD_CONFIG=mysql_release && make -j8
