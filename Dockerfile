FROM binhex/arch-base:latest
MAINTAINER binhex

# additional files
##################

# add supervisor file for application
ADD setup/*.conf /etc/supervisor/conf.d/

# add install bash script
ADD setup/install.sh /root/install.sh

# add packer bash script
ADD setup/packer.sh /root/packer.sh

# add custom environment file for application
ADD setup/setup.sh /home/nobody/setup.sh

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/root/init.sh"]