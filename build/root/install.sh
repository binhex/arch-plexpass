#!/bin/bash

# exit script if return code != 0
set -e

# app name from buildx arg, used in healthcheck to identify app and monitor correct process
APPNAME="${1}"
shift

# release tag name from buildx arg, stripped of build ver using string manipulation
RELEASETAG="${1}"
shift

# target arch from buildx arg
TARGETARCH="${1}"
shift

if [[ -z "${APPNAME}" ]]; then
	echo "[warn] App name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${RELEASETAG}" ]]; then
	echo "[warn] Release tag name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${TARGETARCH}" ]]; then
	echo "[warn] Target architecture name from build arg is empty, exiting script..."
	exit 1
fi

# write APPNAME and RELEASETAG to file to record the app name and release tag used to build the image
echo -e "export APPNAME=${APPNAME}\nexport IMAGE_RELEASE_TAG=${RELEASETAG}\n" >> '/etc/image-build-info'

# ensure we have the latest builds scripts
refresh.sh

# pacman packages
####

# define pacman packages
pacman_packages="git systemd libx264 libvpx ffmpeg libxslt"

# install compiled packages using pacman
if [[ -n "${pacman_packages}" ]]; then
	# arm64 currently targetting aor not archive, so we need to update the system first
	if [[ "${TARGETARCH}" == "arm64" ]]; then
		pacman -Syu --noconfirm
	fi
	pacman -S --needed $pacman_packages --noconfirm
fi

# custom install
####

# ── Paths (set these for your container layout) ─────────────────
PLEX_HOME="${PLEX_HOME:-/usr/lib/plexmediaserver}"
PLEX_DATA="${PLEX_DATA:-/var/lib/plex}"
PLEX_TMP="${PLEX_TMP:-/tmp}"

CHANNEL="5"   # 5 = Plex Pass, 1 = stable
API_URL="https://plex.tv/api/downloads/${CHANNEL}.json"

# ── 1. Fetch latest version from Plex API ───────────────────────
echo "==> Fetching latest version from Plex API..."
API_JSON="$(curl -sSfL "$API_URL")"

VERSION_FULL="$(echo "$API_JSON" | jq -r '.computer.Linux.version')"

VERSION="$(echo "$VERSION_FULL" | cut -d- -f1)"
BUILD="$(echo "$VERSION_FULL" | cut -d- -f2)"

echo "Latest Plex Pass: ${VERSION}-${BUILD}"

# ── 2. Build download URL based on architecture ─────────────────
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    FILE="plexmediaserver-${VERSION}-${BUILD}.x86_64.rpm"
    URL="https://downloads.plex.tv/plex-media-server-new/${VERSION}-${BUILD}/redhat/${FILE}"
    ;;
  aarch64|arm64)
    FILE="plexmediaserver_${VERSION}-${BUILD}_arm64.deb"
    URL="https://downloads.plex.tv/plex-media-server-new/${VERSION}-${BUILD}/debian/${FILE}"
    ;;
  armv7l|armhf)
    FILE="plexmediaserver_${VERSION}-${BUILD}_armhf.deb"
    URL="https://downloads.plex.tv/plex-media-server-new/${VERSION}-${BUILD}/debian/${FILE}"
    ;;
  *)
    echo "ERROR: unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# ── 3. Download ─────────────────────────────────────────────────
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "==> Downloading $URL"
curl -fSL# -o "$WORKDIR/pkg" "$URL"

# ── 4. Extract ──────────────────────────────────────────────────
echo "==> Extracting"
mkdir -p "$WORKDIR/root"
bsdtar -xf "$WORKDIR/pkg" -C "$WORKDIR/root"

# ── 5. Install binaries ─────────────────────────────────────────
echo "==> Installing to $PLEX_HOME"
install -d -m 755 "$PLEX_HOME"
cp -dr --no-preserve=ownership "$WORKDIR/root/usr/lib/plexmediaserver/"* "$PLEX_HOME/"

# ── 6. Create data directory ────────────────────────────────────
install -d -m 755 "$PLEX_DATA"

# aur packages
####

# # define aur packages
# aur_packages="plex-media-server-plexpass"

# # call aur install script (arch user repo)
# aur.sh --aur-package "${aur_packages}"

# github
####

# download ChuckPA's Plex db repair script
github.sh --install-path '/usr/local/bin' --github-owner 'ChuckPa' --github-repo 'DBRepair' --download-assets '.*sh$' --query-type 'release' && chmod +x /usr/local/bin/*.sh

# container perms
####

# define comma separated list of paths
install_paths="/usr/lib/plexmediaserver,/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# In install.sh heredoc, replace the chown section:
cat <<EOF > /tmp/permissions_heredoc
install_paths="${install_paths}"
EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

cat <<'EOF' > /tmp/envvars_heredoc
export TRANS_DIR=$(echo "${TRANS_DIR}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${TRANS_DIR}" ]]; then
	echo "[info] TRANS_DIR defined as '${TRANS_DIR}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] TRANS_DIR not defined,(via -e TRANS_DIR), defaulting to '/config/tmp'" | ts '%Y-%m-%d %H:%M:%.S'
	export TRANS_DIR="/config/tmp"
fi

mkdir -p /config/tmp

EOF

# replace envvar placeholder string with contents of file (here doc)
sed -i '/# ENVVARS_PLACEHOLDER/{
    s/# ENVVARS_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /usr/bin/init.sh
rm /tmp/envvars_heredoc

# cleanup
cleanup.sh
