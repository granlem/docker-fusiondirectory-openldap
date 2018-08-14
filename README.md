# docker-fusiondirectory-openldap
Description:
Use osixia/openldap and configure for fusiondirectory usage. Works perfectly in combination with hrektts/docker-fusiondirectory.

For usage instructions you can read https://github.com/osixia/docker-openldap . The only difference is, that this OpenLDAP server is ready for Fusion Directory. Therefore you have to provide the environment variable "FD_ADMIN_PASSWORD" otherwise the passeword is "adminpassword" (without quotes).

To use Fusion Directory read https://github.com/hrektts/docker-fusiondirectory . It't compatible.

## Quick Start:
An easy way to start quickly is by using the docker-compose.yml.
```
wget https://raw.githubusercontent.com/granlem/docker-fusiondirectory-openldap/master/example/docker-compose.yml
docker-compose up
``` 
Then you can access the Fusion Directory at http://localhost:10080/fd/.
