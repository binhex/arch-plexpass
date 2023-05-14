#!/bin/bash

# fail fast
set -e

datetime=$(date +%Y%m%d%H%M%S)
plex_location="/usr/lib/plexmediaserver"
plex_db_filename="com.plexapp.plugins.library.db"
plex_db_backup_filename="${plex_db_filename}.backup.${datetime}"
plex_db_recovery_filename="${plex_db_filename}.recovered.${datetime}"
plex_appdata_path="/config/Plex Media Server"

function killplex()
{
	plex_pid=$(pgrep -f 'Plex Media Server' || true)
	if [[ -n "${plex_pid}" ]]; then
		echo "[INFO] Stopping Plex Media Server by sending kill to PID '${plex_pid}'"
		kill "${plex_pid}" || true
	else
		echo "[INFO] Plex Media Server not running, skipping kill process."
	fi
}

function backupdb()
{
	if [[ ! -f "${plex_db_backup_filename}" ]]; then
		cp "${plex_db_filename}" "${plex_db_backup_filename}"
		echo "[INFO] Backup of existing database to filename '${plex_db_backup_filename}' has been performed."
	else
		echo "[INFO] Backup of existing database already exists, skipping backup."
	fi
}

function setup()
{
	# create sqlite query files
	echo 'VACUUM;' > /tmp/rebuild-data-structure.sql
	echo 'PRAGMA integrity_check;' > /tmp/check-integrity.sql
	echo 'REINDEX;' > /tmp/rebuild-indexes.sql
	echo ".output ${plex_db_recovery_filename}.sqlite" > /tmp/low-level-db-recovery.sql
	echo '.recover' >> /tmp/low-level-db-recovery.sql
	echo ".read ${plex_db_recovery_filename}.sqlite" > /tmp/read-db-recovery.sql

	# prefix path to plex sqlite binary to path
	PATH="${plex_location}":$PATH

	# go to location of plex db's
	cd "${plex_appdata_path}/Plug-in Support/Databases"
}

function confirm()
{
	opt="${1}"
	read -p "Selected operation '${opt}' will stop Plex Media Server, do you want to continue? " -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		return 0
	else
		return 1
	fi
}

function sqlite()
{
	sqlite_filename="${1}"
	echo "[INFO] Executing SQLite query in filename '${sqlite_filename}'..."
	"Plex SQLite" "${plex_db_filename}" < "${sqlite_filename}"
}

function prompt()
{
	PS3='Please select the Plex DB repair operation: '
	options=("Check integrity" "Repair structure (basic repair)" "Rebuild indexes" "Low-level recovery" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Check integrity")
				if confirm "${opt}"; then
					killplex
				else
					break
				fi
				backupdb
				sqlite '/tmp/check-integrity.sql'
				;;
			"Repair structure (basic repair)")
				if confirm "${opt}"; then
					killplex
				else
					break
				fi
				backupdb
				sqlite '/tmp/rebuild-data-structure.sql'
				;;
			"Rebuild indexes")
				if confirm "${opt}"; then
					killplex
				else
					break
				fi
				backupdb
				sqlite '/tmp/rebuild-indexes.sql'
				;;
			"Low-level recovery")
				if confirm "${opt}"; then
					killplex
				else
					break
				fi
				backupdb
				sqlite '/tmp/low-level-db-recovery.sql'
				mv "${plex_db_filename}" "${plex_db_recovery_filename}"
				sqlite '/tmp/read-db-recovery.sql'
				;;
			"Quit")
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
}

function finish()
{
	echo "[INFO] Repair operation complete, setting ownership and permissions for repaired db..."
	chown nobody:users "${plex_db_filename}"
	chmod 775 "${plex_db_filename}"

	echo "[INFO] Cleaning up files from repair operation..."
	rm -f /tmp/*.sql

	echo
	echo "[INFO] Please now restart the container, script finished."
}

echo "[INFO] Plex Media Server database repair script - written by binhex."
setup
prompt
finish