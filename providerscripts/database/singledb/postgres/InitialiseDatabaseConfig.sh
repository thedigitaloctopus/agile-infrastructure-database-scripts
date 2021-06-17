    /usr/sbin/service postgresql restart
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data/ -l /home/postgres/logfile"
    fi
    
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE USER ${DB_U} WITH ENCRYPTED PASSWORD '${DB_P}';"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "ALTER USER ${DB_U} WITH SUPERUSER;"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
    if ( [ "$?" != "0" ] )
    then   
        /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8' TEMPLATE template0;"
    fi
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_N} to ${DB_U};"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "ALTER USER postgres PASSWORD '${DB_P}';"
   
   # /bin/sed -i "s/trust/md5/g" ${postgres_config}

    /bin/rm ${postgres_pid}
            
   /usr/sbin/service postgresql reload
   if ( [ "$?" != "0" ] )
   then
      /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
   fi
