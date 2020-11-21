DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"

HOST="`/bin/ls ${HOME}/config/databaseip/* | /usr/bin/awk -F'/' '{print $NF}'`"
PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

/usr/bin/mysql -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${PORT}"
