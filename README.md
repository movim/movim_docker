# movim_docker

Movim is a decentralized social network, written in PHP and HTML5 and based on the XMPP standard protocol.

You can find the official repository and download the source code [here](https://github.com/movim/movim). This repository purely contains a Docker Compose solution to get the client quickly set up anywhere. Running this docker-compose file will build a stack comprising an nginx container, a PHP container (where Movim itself resides) and a PostgreSQL container. This setup assumes that you already have an XMPP server such as [ejabberd](https://www.ejabberd.im/) or [Prosody](https://www.prosody.im/) running somewhere else.
