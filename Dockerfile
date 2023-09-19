FROM binhex/arch-base:latest
LABEL org.opencontainers.image.authors = "binhex"
LABEL org.opencontainers.image.source = "https://github.com/binhex/arch-plexpass"

# additional files
##################

# add supervisor file for application
ADD build/*.conf /etc/supervisor/conf.d/

# add install bash script
ADD build/root/*.sh /root/

# get release tag name from build arg
arg RELEASETAG

# add run bash script
ADD run/nobody/*.sh /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh "${RELEASETAG}"

# docker settings
#################

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]