if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    prefix="`${HOME}/providerscripts/utilities/ConnectToDB.sh "show tables" | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
    userdetails="`${HOME}/providerscripts/utilities/ConnectToDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_users"`"

   nousers="`/bin/echo ${userdetails} | /usr/bin/awk -F'::' '{print NF-1}'`"

   if ( [ -f ${HOME}/config/credentials/htpasswd ] )
   then
        liveusers="`/usr/bin/wc -l ${HOME}/config/credentials/htpasswd | /usr/bin/awk '{print $1}'`"
   else
        /bin/touch ${HOME}/config/credentials/htpasswd 
        liveusers="0"
   fi

   if ( [ "${nousers}" != "${liveusers}" ] )
   then
   for user in ${userdetails}
   do
       username="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $1}'`"
       email="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $2}'`"
       if ( [ "`/bin/grep ${username} ${HOME}/config/credentials/htpasswd`" = "" ] && [ "`/bin/grep ${email} ${HOME}/config/credentials/htpasswd`" = "" ] ) 
       then
           /bin/echo "${username}:password" >> ${HOME}/config/credentials/htpasswd
       fi
   done
   else
      echo "not updating"
   fi
fi
