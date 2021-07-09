set -x
username="${1}"
old_password="${2}"
new_password="${3}"

HOST=""
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/bin/echo "ALTER USER \"${username}\"@'localhost' IDENTIFIED BY \"${new_password}\";
ALTER USER \"${username}\"@'127.0.0.1' IDENTIFIED BY \"${new_password}\";
ALTER USER \"${username}\"@\"${HOST}\" IDENTIFIED BY \"${new_password}\";
ALTER USER \"${username}\"@\"${IP_MASK}\" IDENTIFIED BY \"${new_password}\";" > ${HOME}/runtime/resetpasswordDB.sql


    /usr/bin/mysql -f -A -u ${username} -p${old_password} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/resetpasswordDB.sql
fi
