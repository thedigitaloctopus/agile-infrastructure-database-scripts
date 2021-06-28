

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "0" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "0" ] )
then
   exit
fi

DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS-secured`" = "1" ] )
then
    HOST="127.0.0.1"
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

ips="`/bin/ls ${HOME}/config/webserverips`"

if ( [ "${ips}" = "" ] )
then
    exit
fi

for ip in ${ips}
do
    IPMASK="`/bin/echo $ip | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`"
    IPMASK=${IPMASK}".%.%" 
    /usr/bin/mysql -A -u root -p${DB_P} --host="localhost" --port="${DB_PORT}" -e "CREATE USER \"${DB_U}\"@'${IPMASK}' IDENTIFIED BY '${DB_P}';"
    /usr/bin/mysql -A -u root -p${DB_P} --host="localhost" --port="${DB_PORT}" -e "GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${IPMASK}\" WITH GRANT OPTION;"
done
