# docker-fusiondirectory-openldap
## Description:
This openLDAP Server (Dockerimage) uses osixia/openldap and is configured for usage with Fusion Directory. Works perfectly in combination with hrektts/docker-fusiondirectory.

For closer usage instructions you can read https://github.com/osixia/docker-openldap. The only difference is, that this OpenLDAP server is configured for Fusion Directory. Therefore you have to provide the environment variable "FD_ADMIN_PASSWORD" otherwise the password is "adminpassword" (without quotes).

You will need the Docker Fusion Directory as well. You will find a compatible version at https://github.com/hrektts/docker-fusiondirectory.

The documentation for Fusion Directory may also helps: https://docs.fusiondirectory.org/start

## Quick Start:
An easy way to start quickly is by using the docker-compose.yml.
```
wget https://raw.githubusercontent.com/granlem/docker-fusiondirectory-openldap/master/example/docker-compose.yml
docker-compose up
``` 
Then you can access the Fusion Directory at http://localhost:10080/fd/.
