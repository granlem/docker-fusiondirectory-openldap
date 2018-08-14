FROM osixia/openldap:1.2.1
LABEL maintainer="kontakt@maximeveit.de" \
      version="1.2-1"


ENV FUSIONDIRECTORY_VERSION=1.2-1

# Add gpg keys from officual fusiondirectory
# https://documentation.fusiondirectory.org/en/documentation/admin_get_ggp_keys
# Multiple keyservers as workaround because dockerhub seems to have problems with the gnupg keyserver
# - See: https://github.com/nodejs/docker-node/issues/380#issuecomment-348464695
ENV GPG_KEYS="0xD744D55EACDA69FF"
RUN ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "${GPG_KEYS}" \
  || gpg --keyserver pgp.mit.edu --recv-keys "${GPG_KEYS}" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "${GPG_KEYS}" )
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

# Cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set entrypoint
ADD scripts/* /opt/
ENTRYPOINT ["/opt/run.sh"]


