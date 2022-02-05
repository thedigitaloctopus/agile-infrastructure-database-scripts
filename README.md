The Database part of the Agile Deployment Toolkit can be used to create a single database instance it is also used as a kind of proxy for connecting to remote managed DBaaS instances as well as making our own backups (as functionally required) of databases even if they are remotely hosted.

The application being deployed needs to provide a SQL dump file which can be run against the database. In reality, most people are probably going to want to use the local self managed database instance for development and testing and then used a managed DBaaS for production. 

At the moment the user managed database systems which are supported are mariadb, mysql8 and postgres 14.
