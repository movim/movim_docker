# Quick reference

-	**Where to get help**:
	the Movim XMPP MUC - movim@conference.movim.eu

-	**Where to file issues**:
	[https://github.com/movim/movim_docker/issues](https://github.com/movim/movim_docker/issues)

# What is Movim?

Movim is a distributed social network built on top of XMPP, a popular open standards communication protocol. Movim is a free and open source software licensed under the AGPL. It can be accessed using existing XMPP clients and Jabber accounts. Learn more at [movim.eu](https://movim.eu/).

> [wikipedia.org/wiki/Movim](https://en.wikipedia.org/wiki/Movim)

![logo](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Movim-logo.svg/354px-Movim-logo.svg.png)

# How to use this image

## ... via [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose)

Example `stack.yml` for `movim`:

```yaml
services:
  movim:
    environment:
      DAEMON_URL: http://localhost
      DAEMON_PORT: 8080
      DAEMON_INTERFACE: 0.0.0.0
      DB_DRIVER: pgsql
      DB_HOST: postgresql
      DB_PORT: 5432
      DB_DATABASE: movim
      DB_USERNAME: movim
      DB_PASSWORD: changeme
    image: movim/movim:0.21.1
    volumes:
    - ${PWD}/movim:/var/www/html:rw

  nginx:
    image: nginx:mainline-alpine
    ports:
    - published: 80
      target: 80
    volumes:
    - ${PWD}/movim:/var/www/html:ro
    - ${PWD}/nginx:/etc/nginx/conf.d:ro

  postgresql:
    environment:
      POSTGRES_DB: movim
      POSTGRES_PASSWORD: changeme
      POSTGRES_USER: movim
    image: postgres:15-alpine
    volumes:
    - ${PWD}/postgres/data:/var/lib/postgresql/data:rw
version: '3.8'
```
Please note, you'll need to create the `nginx/default.conf` file yourself, to be mounted into the `nginx` container. You can find a good example configuration [here](https://gist.githubusercontent.com/kawaii/468f24135bc5cf817b922d8491276771/raw/bc0a881c5a505ffa677655f515502533d33b7174/movim.conf).

## Environment variables as Docker secrets

Environment variables related to [movim](https://github.com/movim/movim/blob/master/.env.example) may also be created using `Docker secrets`. The corresponding environment variables need a `__FILE` suffix, e.g.:

```yaml
secrets:
  db_password:
    file: /path/to/db_password

services:
  movim:
    environment:
      DAEMON_URL: http://localhost
      DAEMON_PORT: 8080
      DAEMON_INTERFACE: 127.0.0.1
      DB_DRIVER: pgsql
      DB_HOST: postgresql
      DB_PORT: 5432
      DB_DATABASE: movim
      DB_USERNAME: movim
      DB_PASSWORD__FILE: /run/secrets/db_password
      ...
```

# Creating an Admin User

After you've sucessfully logged in to your Movim Pod, run the following Docker Compose exec command;

```
docker-compose exec movim php daemon.php setAdmin example@movim.eu
```
