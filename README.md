# Application

[Plex Pass](https://plex.tv/)

## Description

The Plex Media Server enriches your life by organizing all your personal media,
presenting it beautifully and streaming it to all of your devices. It's easy to
use, it's awesome, and it's free!

## Build notes

Latest stable Plex Media Server (Plex Pass) release from Arch Linux AUR.

## Usage

```bash
docker run -d \

    --net="host" \
    --name=<container name> \
    -v <path for media files>:/media \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \

    binhex/arch-plexpass

```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access application

`http://<host ip>:32400/web`

## Example

```bash
docker run -d \

    --net="host" \
    --name=plex \
    -v /media/movies:/media \
    -v /apps/docker/plex:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \

    binhex/arch-plexpass

```

## Notes

User ID (PUID) and Group ID (PGID) can be found by issuing the following command
for the user you want to run the container as:-

```bash
id <username>

```

You cannot specify the port the docker container uses, it requires full access
to the hosts nic and thus the -p flag is not used.
___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](http://forums.unraid.net/index.php?topic=45845.0)
