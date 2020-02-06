The Database part of the Agile Deployment Toolkit can be used to create a single database instance it is also used as a kind of proxy for connecting to remote DBaaS instances as well as making our own backups of databases even if they are remotely hosted.

The application being deployed needs to provide a SQL configuration file which can be run against the database. In reality, most people are probably going to want to use the local database instance for development and testing and then used a managed DBaaS for production. 

For many applications which aren't critical applications a single database instance should be sufficient. Please remember, however, with a single database instance, if you are deploying n webservers, then all the requests and processing from those webservers are being routed to a single database which can make a performance bottleneck. 
