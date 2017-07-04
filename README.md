# movim_docker

Movim is a decentralized social network, written in PHP and HTML5 and based on the XMPP standard protocol.

You can find the official repository and download the source code [here](https://github.com/movim/movim). This repository purely contains a Docker Compose solution to get the client quickly set up anywhere. Running this docker-compose file will build a stack comprising an nginx container, a PHP container (where Movim itself resides) and a PostgreSQL container. This setup assumes that you already have an XMPP server such as [ejabberd](https://www.ejabberd.im/) or [Prosody](https://www.prosody.im/) running somewhere else.

## Getting Started

Clone this repository to a local directory on your server/workstation. I recommend /opt/docker/movim/ but anywhere your user account has access to will probably be fine.
```
git clone git@github.com:kawaii/movim_docker.git /opt/docker/movim/
```
You should notice a file within the new /movim_docker/ directory called movim.env. You need to edit the default vaues contained within this file.
```
# the domain or subdomain where your Movim instance is served from
NGINX_VHOST=localhost

# copy the value you wrote above here, keeping the http:// prefix and trailing slash
MOVIM_DOMAIN=http://localhost/

# there isn't really much reason to change this
MOVIM_PORT=8080

# there isn't really much reason to change this
MOVIM_INTERFACE=0.0.0.0

# edit this value to your liking
POSTGRES_USER=movim

# please change this, please!
POSTGRES_PASSWORD=movimpassword

# edit this value to your liking
POSTGRES_DB=movim
```
Save your changes and run Docker Compose to raise the stack.
```
docker-compose up -d
```
The first time you run this, PostgreSQL will need a few moments to initialize properly - so be patient while it does so. You will notice some scary looking errors in the log or on screen if you didn't run Docker in detached mode, these are normal the first time you run it. After a few minutes point your browser towards the nginx VHOST you configured within the movim.env file and you should see your shiny new Movim Pod! Any subsequent times you start this container set will be much faster.
