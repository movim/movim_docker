# Quick reference

-	**Where to get help**:
	the Movim XMPP MUC - movim@conference.movim.eu

-	**Where to file issues**:
	[https://github.com/movim/movim_docker/issues](https://github.com/movim/movim_docker/issues)

# What is Movim?

Movim is a distributed social network built on top of XMPP, a popular open standards communication protocol. Movim is a free and open source software licensed under the AGPL. It can be accessed using existing XMPP clients and Jabber accounts. Learn more at [movim.eu](https://movim.eu/).

> [wikipedia.org/wiki/Movim](https://en.wikipedia.org/wiki/Movim)

![logo](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Movim-logo.svg/354px-Movim-logo.svg.png)

# Image description and usage

* built for `x86-64` and `arm64`
* runs as non-root user
* does not require any Linux capabilities
* built with `php8`
* `s6-overlay` to manage the different processes
* (is available also as an Alpine based image, which has an [issue](https://github.com/sando38/movim/issues/1), however)

## Tags

The image name is `ghcr.io/movim/movim`. Images are available from tag `v0.21rc3` onwards. For older image versions, see [DockerHub](https://hub.docker.com/r/movim/movim).

Experimental Alpine based images have an `-alpine` suffix.

| Tags  | Description  | Additional notes  |
| ------------ | ------------ | ------------ |
| `v0.21rc3`, `latest`  | [Release changelog](https://github.com/movim/movim/blob/master/CHANGELOG.md)  |   |

All images are based upon the official `php-fpm` docker images with latest OS (e.g. `Debian bullseye`).

## Configuration (overview)

The easiest way is to clone the repo:

    git clone https://github.com/movim/movim_docker

Afterwards, those two files need to be adjusted:

* docker-compose.yml
* movim.env

If both have been adjusted, start the stack with:

    docker compose up -d

Movim starts [w/o any admins](https://github.com/movim/movim/blob/master/INSTALL.md#5-admin-panel). An admin could be defined with:

    docker exec movim php daemon.php setAdmin {jid}

### docker-compose.yml

There are some aspects to double check:

* Image build vs. pre-build image
* `movim` security options
* `postgresql` configuration
* `nginx` configuration

You need to decide wether to `build` the image yourself or to use the pre-build `image` (default). Either way, one of the parts must be commented:

```yml
services:
  movim:
<<<<<<< HEAD
    environment:
      MOVIM_DOMAIN: http://localhost
      MOVIM_PORT: 8080
      MOVIM_INTERFACE: 0.0.0.0
      POSTGRES_DB: movim
      POSTGRES_HOST: postgresql
      POSTGRES_PORT: 5432
      POSTGRES_USER: movim
      POSTGRES_PASSWORD: changeme
    image: movim/movim:0.21rc3
    volumes:
    - ${PWD}/movim:/var/www/html:rw
=======
    ### general settings
    image: ghcr.io/movim/movim:latest
    #build:
    #  context: image/.
    #  dockerfile: Dockerfile.debian
    ...
```
>>>>>>> d53fa9c (Rework Docker image:)

The image is designed to run without any privileges/ linux capabilities. If you want that, you can uncomment the following parts:

```
services:
  movim:
    ...
    ### security options
    read_only: true
    #cap_drop: [ALL]
    #security_opt:
    #  - no-new-privileges:true
    ...
```

Additionally, movim relies on a database server. It works with `postgresql` (recommended) or `mysql`/`mariadb`. If you run a database server already, you should comment the `postgresql` part of the `docker-compose.yml` file. If not, at least the `POSTGRES_PASSWORD` should be changed to something save. This password must be the same as provided to movim with the variable `DB_PASSWORD`, e.g. within the `movim.env` file.

```yml
  ...
  postgresql:
    hostname: postgresql
    container_name: postgresql
    image: postgres:14-alpine
    ...
```

Lastly, check the provided `nginx` configuration. Either you use an already existing webserver or this configuration. This repo also provides some [configuration examples](appdata/nginx) for nginx (w/ and w/o TLS). If TLS certificates are mounted into the container, the nginx user (`101:101`) should be able to read them.

### movim.env

This file contains the environment variables, which are read by movim during startup. Here is the link to the official installation document from the movim repository:

[https://github.com/movim/movim/blob/master/INSTALL.md#2-dotenv-configuration](https://github.com/movim/movim/blob/master/INSTALL.md#2-dotenv-configuration)

The `DB_PASSWORD` environment variable can also be exchanged with `DB_PASSWORD_FILE` which makes use of Docker secrets.

## ToDos

Potential ToDos for the future:

* Fix Alpine container image
* Integrate nginx into the movim image

## Feedback

Feel free to provide feedback. If there is an issue or anything, please use the issue tracker.
