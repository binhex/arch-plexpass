#!/usr/bin/dumb-init /bin/bash

# source in script to wait for child processes to exit
source waitproc.sh

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

# if PLEX_CLAIM set then edit Preferences before running pms
# see https://support.plex.tv/articles/204281528-why-am-i-locked-out-of-server-settings-and-how-do-i-get-in/
if [[ -n "${PLEX_CLAIM}" && "${CLAIM_SERVER}" == 'yes' ]]; then
	sed -i -E 's~PlexOnlineMail="[^"]+"~PlexOnlineMail=""~g' '/config/Plex Media Server/Preferences.xml'
	sed -i -E 's~PlexOnlineToken="[^"]+"~PlexOnlineToken=""~g' '/config/Plex Media Server/Preferences.xml'
	sed -i -E 's~PlexOnlineUsername="[^"]+"~PlexOnlineUsername=""~g' '/config/Plex Media Server/Preferences.xml'
	sed -i -E 's~PlexOnlineHome="[^"]+"~PlexOnlineHome=""~g' '/config/Plex Media Server/Preferences.xml'
else
	echo "[info] Env var 'PLEX_CLAIM' value not set and/or 'CLAIM_SERVER' not set to 'yes', skipping edit of Preferences.xml for claim process."
fi

# kick off main process
"${PLEX_MEDIA_SERVER_HOME}/Plex Media Server"
