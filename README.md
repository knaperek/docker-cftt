# docker-cftt
CF TLS Terminator for Docker services

## Target Audience
This project provides a base Dockerfile to be simply inherited and plugged in to your web service deployment configuration assuming you have the following setup:

* hosting one or more web services on Docker Engine (single or Swarm)
* using CF as a reverse proxy

## Objectives
* easy TLS configuration **decoupled** from the web service itself
* prevent unauthorized access from sources other than CF
* allow web services for multiple domains to be served from the same server and port (CF does not support specifying a custom downstream port)

## Solution
We keep all the web services do their job and not bother them with any TLS configurations. Instead a single **stunnel** TLS proxy is launched and automatically configured based on origin TLS keys and certs supplied (during the build process) for each deployed service.

All individual web services only need to **expose** their plain HTTP ports (80) which **are not mapped** to the host machine. Only the stunnel's HTTPS port (443) needs to be mapped (`-p443:443`) and thus made publicly accessible.

## Requirements
This is a base Docker image which makes use of the `ONBUILD` instructions, so you need to make your own `Dockerfile` which may be as simple as just defining the `FROM` instruction, providing the following conditions are met:
* all service TLS keys need to be placed in a local folder named `keys/` (alongside your custom Dockerfile)
* similarly, all service certificates should be placed in `certs/`
* both keys and certs need to be in the `PEM` format
* **IMPORTANT**: both key and cert files need to conform to this filename pattern: `<service-FQDN>.pem`, e.g. `example.com.pem`

## Example with Docker Compose
#### docker-compose.yml
```
version: '3.4'
services:
  web1.example.com:
    image: nginx
    expose:
      - "80"
  web2.example.com:
    image: nginx
    expose:
      - "80"
  stunnel:
    build: .
    ports:
      - "443:443"
```
#### Dockerfile for stunnel
```
FROM knaperek/cftt
```
#### Key files
* `keys/web1.example.com.pem`
* `keys/web2.example.com.pem`

#### Cert files
* `certs/web1.example.com.pem`
* `certs/web2.example.com.pem`

