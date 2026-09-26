#!/usr/bin/dumb-init /bin/bash

plex_media_server_config_path='/config/Plex Media Server'

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
	sed -i -E 's~PlexOnlineMail="[^"]+"~PlexOnlineMail=""~g' "${plex_media_server_config_path}/Preferences.xml"
	sed -i -E 's~PlexOnlineToken="[^"]+"~PlexOnlineToken=""~g' "${plex_media_server_config_path}/Preferences.xml"
	sed -i -E 's~PlexOnlineUsername="[^"]+"~PlexOnlineUsername=""~g' "${plex_media_server_config_path}/Preferences.xml"
	sed -i -E 's~PlexOnlineHome="[^"]+"~PlexOnlineHome=""~g' "${plex_media_server_config_path}/Preferences.xml"
else
	echo "[info] Env var 'PLEX_CLAIM' value not set and/or 'CLAIM_SERVER' not set to 'yes', skipping edit of Preferences.xml for claim process."
fi

echo "[INFO] Removing any existing Plex Media Server PID..."
rm -f "${plex_media_server_config_path}/plexmediaserver.pid"

echo "[INFO] Ensure encoder binaries are executable..."
chmod -R 775 "${plex_media_server_config_path}/Codecs/EasyAudioEncoder"*

echo "[info] Starting Plex Media Server..."
exec "${PLEX_MEDIA_SERVER_HOME}/Plex Media Server"