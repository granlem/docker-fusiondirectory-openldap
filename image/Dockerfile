FROM osixia/openldap:1.2.1
LABEL maintainer="kontakt@maximeveit.de" \
      version="1.2-1"


ENV FUSIONDIRECTORY_VERSION=1.2-1

# Add gpg keys from officual fusiondirectory
# https://documentation.fusiondirectory.org/en/documentation/admin_get_ggp_keys
RUN gpg --keyserver keys.gnupg.net --recv-key 0xD744D55EACDA69FF
RUN gpg --export -a "FusionDirectory Project Signing Key <contact@fusiondirectory.org>" > FD-archive-key
RUN apt-key add FD-archive-key

# Add source of fusiondirectory and update apt
# https://www.fusiondirectory.org/download/debian-2/
RUN (echo "deb http://repos.fusiondirectory.org/fusiondirectory-current/debian-stretch stretch main"; \
     echo "deb http://repos.fusiondirectory.org/fusiondirectory-extra/debian-jessie jessie main") \
    > /etc/apt/sources.list.d/fusiondirectory-stretch.list \
    && apt-get update


# Install fusiondirctory-schema and insert schema with the official script
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends fusiondirectory-schema \
    && apt-get install -yq --no-install-recommends fusiondirectory-plugin-systems fusiondirectory-plugin-systems-schema

ADD res/run.sh /opt/run.sh
ENTRYPOINT ["/opt/run.sh"]


