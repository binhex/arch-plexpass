**Application**

[Plex Pass](https://plex.tv/)

**Application description**

The Plex Media Server enriches your life by organizing all your personal media, presenting it beautifully and streaming it to all of your devices. It's easy to use, it's awesome, and it's free![

**Build notes**

Latest stable Plex Media Server (Plex Pass) release from Arch Linux AUR using Packer to compile.

**Usage**
```
docker run -d \
	--net="host" \
	--name=<container name> \
	-v <path for media files>:/media \
	-v <path for config files>:/config \
	-v /etc/localtime:/etc/localtime:ro \
	binhex/arch-plex

```

Please replace all user variables in the above command defined by <> with the correct values.

**Access application**

`http://<host ip>:32400/web`

**Example**
```
docker run -d \
	--net="host" \
	--name=plex \
	-v /media/movies:/media \
	-v /apps/docker/plex:/config \
	-v /etc/localtime:/etc/localtime:ro \
	binhex/arch-plex
```

**Notes**

You cannot specify the port the docker container uses, it requires full access to the hosts nic and thus the -p flag is not used.

[Support forum](http://lime-technology.com/forum/index.php?topic=45845.0)