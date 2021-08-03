# /etc/apt/sources.list
# uncomment deb-src
# run apt update
#deb http://ftp.debian.org/debian buster main contrib
#deb http://security.debian.org buster/updates main contrib
#deb-src http://ftp.debian.org/debian buster main contrib
#deb-src  http://security.debian.org buster/updates main contrib

/usr/bin/apt-get install -qq -y build-essential bison cmake
/usr/bin/apt-get -qq -y build-dep mariadb-server 
/usr/bin/git clone https://github.com/MariaDB/server.git
cd server
mariadb_version="`/usr/bin/wget -qO- https://mariadb.com/kb/en/release-notes/ | /bin/grep "MariaDB" | /bin/grep "Release Notes" | /usr/bin/head -n 1 | /bin/sed 's/.*MariaDB //g' | /usr/bin/awk -F' ' '{print $1}'`"
/usr/bin/git checkout ${mariadb_version}
#./BUILD/compile-amd64-max

#/usr/bin/cmake . -DBUILD_CONFIG=mysql_release && make -j8
/usr/bin/cmake -DBUILD_CONFIG=mysql_release
/usr/bin/make
/usr/bin/make install
/usr/sbin/mysqld
