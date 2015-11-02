FROM binhex/arch-base:2015080700
MAINTAINER binhex

# additional files
##################

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

# rar2fs setup
##############
ADD rar2fs.sh /home/nobody/rar2fs.sh
RUN chmod +x /home/nobody/*.sh

# docker settings
#################

# add supervisor file for application
ADD *.conf /etc/supervisor/conf.d/

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]