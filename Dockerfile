FROM binhex/arch-base:2015080700
MAINTAINER binhex

# additional files
##################

# add supervisor file for application
ADD *.conf /etc/supervisor/conf.d/

# add install bash script
ADD install.sh /root/install.sh

# add packer bash script
ADD packer.sh /root/packer.sh

# add custom environment file for application
ADD setup.sh /home/nobody/setup.sh

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

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]