# freekers/docker-plex

This is a fork of linuxserver/docker-plex with a small personal customization: phantomjs (including it's dependency called 'libfontconfig') has been added to this image, for use with the FMoviesPlus.bundle

To setup FMoviesPlus.bundle, please refer to their Wiki: https://github.com/coder-alpha/FMoviesPlus.bundle/wiki

For the 'Absolute path to PhantomJS folder (folder containing the binary file)', use: `/opt/phantomjs-2.1.1-linux-x86_64/bin`

The image is automatically / rebuild whenever the base image is updated on Docker Hub (i.e. linuxserver:docker-plex).

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=plex \
  --net=host \
  -e PUID=1001 \
  -e PGID=1001 \
  -e VERSION=docker \
  -v </path/to/library>:/config \
  -v <path/to/tvseries>:/data/tvshows \
  -v </path/to/movies>:/data/movies \
  -v </path for transcoding>:/transcode \
  --restart unless-stopped \
  freekers/plex
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  plex:
    image: freekers/plex
    container_name: plex
    network_mode: host
    environment:
      - PUID=1001
      - PGID=1001
      - VERSION=docker
    volumes:
      - </path/to/library>:/config
      - <path/to/tvseries>:/data/tvshows
      - </path/to/movies>:/data/movies
      - </path for transcoding>:/transcode
    mem_limit: 4096m
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `--net=host` | Use Host Networking |
| `-e PUID=1001` | for UserID - see below for explanation |
| `-e PGID=1001` | for GroupID - see below for explanation |
| `-e VERSION=docker` | Set whether to update plex or not - see Application Setup section. |
| `-v /config` | Plex library location. *This can grow very large, 50gb+ is likely for a large collection.* |
| `-v /data/tvshows` | Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc. |
| `-v /data/movies` | Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc. |
| `-v /transcode` | Path for transcoding folder, *optional*. |

## Optional Parameters

*Special note* - If you'd like to run Plex without requiring `--net=host` (`NOT recommended`) then you will need the following ports in your `docker create` command:

```
  -p 32400:32400 \
  -p 32400:32400/udp \
  -p 32469:32469 \
  -p 32469:32469/udp \
  -p 5353:5353/udp \
  -p 1900:1900/udp
```

The application accepts a series of environment variables to further customize itself on boot:

| Parameter | Function |
| :---: | --- |
| `-v /transcode` | Path for transcoding folder|
| `--device=/dev/dri:/dev/dri` | Add this option to your run command if you plan on using Quicksync hardware acceleration - see Application Setup section.|


## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```


&nbsp;
## Application Setup

Webui can be found at `<your-ip>:32400/web`

** Note about updates, if there is no value set for the VERSION variable, then no updates will take place.**

** For new users, no updates will take place on the first run of the container as there is no preferences file to read your token from, to update restart the Docker container after logging in through the webui**

Valid settings for VERSION are:-

`IMPORTANT NOTE:- YOU CANNOT UPDATE TO A PLEXPASS ONLY (BETA) VERSION IF YOU ARE NOT LOGGED IN WITH A PLEXPASS ACCOUNT`

+ **`docker`**: Let Docker handle the Plex Version, we keep our Dockerhub Endpoint up to date with the latest public builds. This is the same as leaving this setting out of your create command.
+ **`latest`**: will update plex to the latest version available that you are entitled to.
+ **`public`**: will update plexpass users to the latest public version, useful for plexpass users that don't want to be on the bleeding edge but still want the latest public updates.
+ **`<specific-version>`**: will select a specific version (eg 0.9.12.4.1192-9a47d21) of plex to install, note you cannot use this to access plexpass versions if you do not have plexpass.

Hardware acceleration users for Intel Quicksync will need to mount their /dev/dri video device inside of the container by passing the following command when running or creating the container:

```--device=/dev/dri:/dev/dri```

We will automatically ensure the abc user inside of the container has the proper permissions to access this device.

Hardware acceleration users for Nvidia will need to install the container runtime provided by Nvidia on their host, instructions can be found here:

https://github.com/NVIDIA/nvidia-docker

We automatically add the necessary environment variable that will utilise all the features available on a GPU on the host. Once nvidia-docker is installed on your host you will need to re/create the docker container with the nvidia container runtime `--runtime=nvidia` and add an environment variable `-e NVIDIA_VISIBLE_DEVICES=all` (can also be set to a specific gpu's UUID, this can be discovered by running `nvidia-smi --query-gpu=gpu_name,gpu_uuid --format=csv` ). NVIDIA automatically mounts the GPU and drivers from your host into the plex docker.



## Support Info

* Shell access whilst the container is running: `docker exec -it plex /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f plex`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' plex`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' freekers/plex`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  

Below are the instructions for updating containers:  

### Via Docker Run/Create
* Update the image: `docker pull freekers/plex`
* Stop the running container: `docker stop plex`
* Delete the container: `docker rm plex`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start plex`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update the image: `docker-compose pull freekers/plex`
* Let compose update containers as necessary: `docker-compose up -d`
* You can also remove the old dangling images: `docker image prune`
