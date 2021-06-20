#!/bin/sh

export HOME="`/bin/cat /home/homedir.dat`"

if ( [ "${1}" != "" ] && [ "${2}" != "" ] )
then
    /bin/sed -i "/${1}/d" ${HOME}/.ssh/database_configuration_settings.dat
    /bin/echo "${1}:${2}" >> ${HOME}/.ssh/database_configuration_settings.dat
fi
