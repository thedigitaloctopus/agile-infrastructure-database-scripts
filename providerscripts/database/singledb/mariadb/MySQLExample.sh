/usr/bin/mysql -A -u doadmin -pc3u --host=db-mysql-nyc1-62-do-user-21-0.db.ondigitalocean.com --port=25100 -e "use mysql; GRANT ALL PRIVILEGES ON defaultdb.* TO 'doadmin' WITH GRANT OPTION;" ALTER USER 'doadmin' IDENTIFIED WITH mysql_native_password BY 'cj6phdhdhgsxu'; flush privileges;"