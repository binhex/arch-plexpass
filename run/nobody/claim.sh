#!/bin/bash

function wait_for_plex_to_start() {

	echo "[info] Waiting for Plex Media Server initial startup..."
	max_startup_retries=120  # 2 minutes
	startup_retry_count=0

	# ensure initial connectivity
	while [ ${startup_retry_count} -lt ${max_startup_retries} ]; do
		if curl -s "http://localhost:32400/web" > /dev/null; then
			break
		fi
		sleep 1
		startup_retry_count=$((startup_retry_count + 1))
	done

	if [ ${startup_retry_count} -eq ${max_startup_retries} ]; then
		echo "[error] Plex Media Server failed to start within 2 minutes, exiting..."
		exit 1
	fi

	echo "[info] Waiting for Plex Media Server maintenance tasks to finish..."
	max_retries=30
	retry_count=0

	while [ ${retry_count} -lt ${max_retries} ]; do
		response=$(curl -s -X POST "http://localhost:32400/web")
		if echo "${response}" | grep -q "running startup maintenance tasks"; then
			echo "[info] Plex Media Server is running maintenance tasks, waiting 10 seconds before retry (attempt $((retry_count + 1))/${max_retries})..."
			sleep 10
			retry_count=$((retry_count + 1))
		else
			break
		fi
	done

	if [ ${retry_count} -eq ${max_retries} ]; then
		echo "[warn] Maximum retries reached, Plex server may still be in maintenance mode"
	else
		echo "[info] Plex Media Server is running."
	fi

}

function claim_server() {
	echo "[info] Plex Media Server started, sending claim token to local server..."
	response=$(curl -s -X POST "http://localhost:32400/myplex/claim?token=${PLEX_CLAIM}")

	if echo "${response}" | grep -q "401 Unauthorized"; then
		echo "[error] Claim token is invalid or expired. Please generate a new claim token from https://www.plex.tv/claim/"
		echo "[info] Claim response received:"
		echo "${response}"
		exit 1
	else
		echo "[info] Claim response received:"
		echo "${response}"
	fi
}

if [[ -n "${PLEX_CLAIM}" && "${CLAIM_SERVER}" == 'yes' ]]; then
	wait_for_plex_to_start
	claim_server
else
	echo "[info] Env var 'PLEX_CLAIM' value not set and/or 'CLAIM_SERVER' not set to 'yes', skipping claim process."
fi
