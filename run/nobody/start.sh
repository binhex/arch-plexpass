#!/bin/bash

# config below is a consolidation of (original) bash script /usr/bin/plexmediaserver.sh and environment file /etc/conf.d/plexmediaserver

# set env variables for plex
export PLEX_MEDIA_SERVER_USER='nobody'
export PLEX_MEDIA_SERVER_HOME='/usr/lib/plexmediaserver'
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR='/config'
export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS='6'

# if transcode temporary folder not set then use default
if [[ -z "${TRANS_DIR}" ]]; then
	mkdir -p /config/tmp
	export PLEX_MEDIA_SERVER_TMPDIR='/config/tmp'
	export TMPDIR='/config/tmp'
else
	mkdir -p "${TRANS_DIR}"
	export PLEX_MEDIA_SERVER_TMPDIR="${TRANS_DIR}"
	export TMPDIR="${TRANS_DIR}"
fi

# set language variables (required for plex) must be same as locale set in base image
export LANG='en_GB.UTF-8'
export LC_ALL='en_GB.UTF-8'

# this path allows the import of the .so library modules located in the install folder
export LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"

# set home directory, this is where the library files are stored (auto created on run of Plex Media Server)
export HOME='/config'

# kick off main process
exec "${PLEX_MEDIA_SERVER_HOME}/Plex Media Server"
