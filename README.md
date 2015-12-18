**Application**

[Plex Pass](https://plex.tv/)

**Application description**

Plex is a centralized home media playback system with a powerful central server–the Plex Media Server–that streams its media to many Plex player Apps. The Server is available on many platforms like Windows, OS X, and many flavors of Linux, as well as many NAS devices like ReadyNAS or Synology.

**Build notes**

Latest stable release from Arch Linux User Repository (AUR) using Packer to compile.

**Usage**
```
docker run -d 
	--net="host"
	--name=<container name> \
	-v <path for media files>:/media \
	-v <path for config files>:/config \
	-v /etc/localtime:/etc/localtime:ro \
	binhex/arch-couchpotato
```  
Please replace all user variables in the above command defined by <> with the correct values.

**Access application**

http://<host ip>:32400/web

**Example**
```
docker run -d 
	--net="host"
	--name=plexpass \
	-v /media/movies:/media \
	-v /apps/docker/plexpass:/config \
	-v /etc/localtime:/etc/localtime:ro \
	binhex/arch-plexpass
```  
**Notes**

N/A

[Support forum](http://lime-technology.com/forum/index.php?topic=38055.0)