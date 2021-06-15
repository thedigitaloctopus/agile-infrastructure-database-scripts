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
cd postgresql-${version}
./configure --without-readline
/usr/bin/make
/usr/bin/make install
/usr/bin/mkdir /usr/local/pgsql/data
/usr/bin/chown postgres:postgres /usr/local/pgsql/data
/usr/bin/su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data/
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile start
