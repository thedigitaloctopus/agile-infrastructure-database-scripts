HOST=""
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/bin/echo "use mysql;
ALTER USER \"${username}\"@'localhost' IDENTIFIED BY "${password}";
ALTER USER \"${username}\"@'127.0.0.1' IDENTIFIED BY "${password}";
ALTER USER \"${username}\"@\"${HOST}\" IDENTIFIED BY "${password}";
ALTER USER \"${username}\"@\"${IP_MASK}\" IDENTIFIED BY "${password}";
" > ${HOME}/runtime/resetpasswordDB.sql


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    /usr/bin/mysql -f -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/resetpasswordDB.sql
fi
