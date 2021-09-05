cd ${HOME}
if ( [ -d agile-infrastructure-database-scripts ] )
then
    /bin/rm -r agile-infrastructure-database-scripts
fi
infrastructure_repository_owner="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
/usr/bin/git clone https://github.com/${infrastructure_repository_owner}/agile-infrastructure-database-scripts.git
cd agile-infrastructure-database-scripts
/bin/cp -r * ${HOME}
cd ..
/bin/rm -r agile-infrastructure-database-scripts
