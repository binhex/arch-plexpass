FROM ghcr.io/binhex/arch-base:latest
LABEL org.opencontainers.image.authors="binhex"
LABEL org.opencontainers.image.source="https://github.com/binhex/arch-plexpass"

# app name from buildx arg
ARG APPNAME

# release tag name from buildx arg
ARG RELEASETAG

# arch from buildx --platform, e.g. amd64
ARG TARGETARCH

# additional files
##################

# add supervisor file for application
ADD build/*.conf /etc/supervisor/conf.d/

# add install bash script
ADD build/root/*.sh /root/

# add run bash script
ADD run/nobody/*.sh /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh "${APPNAME}" "${RELEASETAG}" "${TARGETARCH}"

# healthcheck
#############

# ensure internet connectivity, used primarily when sharing network with other containers
HEALTHCHECK \
	--interval=2m \
	--timeout=2m \
	--retries=3 \
	--start-period=2m \
  CMD /usr/local/bin/system/scripts/docker/healthcheck.sh || exit 1

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "init.sh"]