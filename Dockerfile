################
# Bitbucket image
################

# Set the base image
FROM registry.access.redhat.com/rhel7

# File Author / Maintainer
MAINTAINER Daniel Haws opax@kadima.solutions

# Build Args
ARG BITBUCKET_VERSION
ARG DOWNLOAD_URL=https://downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz

# Environment variables
ENV BITBUCKET_VERSION   $BITBUCKET_VERSION
ENV RUN_USER            atlbitbucket
ENV RUN_GROUP           devops

# https://confluence.atlassian.com/display/BitbucketServer/Bitbucket+Server+home+directory
ENV BITBUCKET_HOME          /var/atlassian/application-data/bitbucket
ENV BITBUCKET_INSTALL_DIR   /opt/atlassian/bitbucket

# Set JAVA home
ENV JAVA_HOME=/etc/alternatives

# Add the necessary files
COPY epel-release-latest-7.noarch.rpm /
COPY ius-release-1.0-15.ius.el7.noarch.rpm /
COPY docker-cmd.sh /
COPY bitbucket-cfg.sh /

# Set permissions on added files
RUN \
chmod 644 /epel-release-latest-7.noarch.rpm && \
chmod 644 /ius-release-1.0-15.ius.el7.noarch.rpm && \
chmod 744 /docker-cmd.sh && \
chmod 744 /bitbucket-cfg.sh

# Install optional, epel, and ius repos
# And then add necessary programs
RUN \
yum localinstall -y epel-release-latest-7.noarch.rpm && \
yum localinstall -y ius-release-1.0-15.ius.el7.noarch.rpm && \
yum install -y \
git2u-core.x86_64 \
hostname \
java-1.8.0-openjdk.x86_64 \
which \
perl \
gettext && \
yum clean all

# Install Bitbucket
WORKDIR $BITBUCKET_HOME
RUN \
groupadd ${RUN_GROUP} && \
useradd -g ${RUN_GROUP} ${RUN_USER}

RUN mkdir -p                             ${BITBUCKET_INSTALL_DIR} \
    && curl -L --silent                  ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$BITBUCKET_INSTALL_DIR" \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${BITBUCKET_INSTALL_DIR}/ 

# Start Bitbucket this is to allow the container to create the necessary files and directories needed by docker-cmd.sh for the sed operations if the image is above 5.1.2
RUN set -x && \
chown ${RUN_USER}:${RUN_GROUP}     ${BITBUCKET_HOME} && \
su -s /usr/bin/bash "${RUN_USER}" -c "${BITBUCKET_INSTALL_DIR}/bin/start-bitbucket.sh" && \
sleep 30s && \
su -s /usr/bin/bash "${RUN_USER}" -c "${BITBUCKET_INSTALL_DIR}/bin/stop-bitbucket.sh" 

# Expose HTTP and SSH ports
EXPOSE 7990
EXPOSE 7999

# Run this on container startup
CMD ["/docker-cmd.sh"]
