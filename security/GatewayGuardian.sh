#set -x

BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`/usr/bin/s3cmd ls s3://gatewayguardian-${BUILD_IDENTIFIER}`" = "" ] )
then
    /usr/bin/s3cmd mb s3://gatewayguardian-${BUILD_IDENTIFIER}
fi

if ( [ "${1}" = "fromcronreset" ] )
then
    /bin/sleep 10
    /bin/mv ${HOME}/runtime/credentials/htpasswd ${HOME}/runtime/credentials/htpasswd.$$
fi

if ( [ ! -d ${HOME}/runtime/credentials ] )
then
    /bin/mkdir ${HOME}/runtime/credentials
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_users"`"
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT username,email FROM ${prefix}_users" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /bin/grep '_users' | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',user_login,user_email) from ${prefix}_users"`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT user_login,user_email FROM ${prefix}_users" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /bin/grep '_user' | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_user"`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_user" | /usr/bin/tail -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT username,email FROM ${prefix}_user" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /bin/grep '_users_field_data' | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',name,mail) from ${prefix}_users_field_data"`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT name,mail FROM ${prefix}_users_field_data" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "${userdetails}" = "" ] )
then
    userdetails="bootstrap_user::bootstrap@dummyemail.com"
fi

nousers="`/bin/echo ${userdetails} | /usr/bin/awk -F'::' '{print NF-1}'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/credentials/htpasswd ] )
then
    /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$ 
    /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history.$$
fi

if ( [ ! -f ${HOME}/runtime/credentials/htpasswd ] && [ "${1}" != "fromcronreset" ] )
then 
    dir="`/usr/bin/pwd`"
    cd ${HOME}/runtime/credentials
    /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd 
    /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history 
    cd ${dir}
fi

if ( [ -f ${HOME}/runtime/credentials/htpasswd ] )
then
    #liveusers="`/usr/bin/wc -l ${HOME}/runtime/credentials/htpasswd | /usr/bin/awk '{print $1}'`"
    credentials="`/bin/grep -v 'placeholder-for-uid-1' ${HOME}/runtime/credentials/htpasswd`"
    if ( [ "${credentials}" != "" ] )
    then
        liveusers="`/usr/bin/wc -w ${credentials} | /usr/bin/awk '{print $1}'`"
    else
        liveusers="0"
    fi
else
    /bin/touch ${HOME}/runtime/credentials/htpasswd 
    liveusers="0"
fi

if ( [ "${nousers}" != "${liveusers}" ] )
then
   for user in ${userdetails}
   do
       username="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $1}'`"
       email="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $2}'`"
       if ( [ "`/bin/grep ${username} ${HOME}/runtime/credentials/htpasswd`" = "" ] && [ "${username}" != "" ] && [ "${email}" != "" ] ) 
       then
           user_password="`/usr/bin/openssl rand -base64 10`"
           user_password_digest="`/bin/echo "${user_password}" | /usr/bin/openssl passwd -apr1 -stdin`"
           /bin/echo "${username}:${user_password_digest}" >> ${HOME}/runtime/credentials/htpasswd
           /bin/sed -i "/${username}:/s/LIVE:   //g" ${HOME}/runtime/credentials/htpasswd_plaintext_history
           /bin/echo "LIVE:   ${username}:${user_password}:${email}" >> ${HOME}/runtime/credentials/htpasswd_plaintext_history
           /bin/touch ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
           ${HOME}/providerscripts/email/SendEmail.sh "YOUR NEW GATEWAY GUARDIAN PASSWORD" "YOUR NEW GATEWAY GUARDIAN PASSWORD IS (  ${user_password}  ).  Please enter it when prompted with your application username for access to ${WEBSITE_URL}" "${email}"
       fi
   done
fi
   
if ( [ "`/usr/bin/find ${HOME}/runtime/credentials/htpasswd -type f -mmin -1`" != "" ] )
then
    /usr/bin/s3cmd del s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /usr/bin/s3cmd del s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history
    /usr/bin/s3cmd put ${HOME}/runtime/credentials/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/
    /usr/bin/s3cmd put ${HOME}/runtime/credentials/htpasswd_plaintext_history s3://gatewayguardian-${BUILD_IDENTIFIER}/
fi
