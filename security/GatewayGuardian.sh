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
    
    prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
    userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_users"`"
fi

nousers="`/bin/echo ${userdetails} | /usr/bin/awk -F'::' '{print NF-1}'`"

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
    liveusers="`/usr/bin/wc -l ${HOME}/runtime/credentials/htpasswd | /usr/bin/awk '{print $1}'`"
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
       if ( [ "`/bin/grep ${username} ${HOME}/runtime/credentials/htpasswd`" = "" ] ) 
       then
           user_password="`/usr/bin/date +%s | /usr/bin/sha256sum | /usr/bin/base64 | /usr/bin/head -c 10 ; echo`"
           user_password_digest="`/bin/echo "${user_password}" | /usr/bin/openssl passwd -apr1 -stdin`"
           /bin/echo "${username}:${user_password_digest}" >> ${HOME}/runtime/credentials/htpasswd
           /bin/echo "${username}:${user_password}" >> ${HOME}/runtime/credentials/htpasswd_plaintext_history
           /bin/touch ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
           ${HOME}/providerscripts/email/SendEmail.sh "YOUR NEW GATEWAY GUARDIAN PASSWORD" "YOUR NEW GATEWAY GUARDIAN PASSWORD IS ${user_password}. Please enter it with your application username for access to ${WEBSITE_URL}" "${email}"
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
