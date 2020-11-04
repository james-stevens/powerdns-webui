# PowerDNS WebUI Proxy Container

This container runs an NGINX proxy on an Alpine platform to provide per-user 
authentication and HTTPS access to your PowerDNS Server via this javascript webapp.


## Tell PowerDNS we need access

You will need to change your PowerDNS settings so the `webserver-allow-from=` option
includes the IP Address your container will be assigned. You can add your
container subnet, if you are unsure what IP Address it will be assigned


## Change the Default Login

The only default login is user-name `admin`, and password `admin`. You need to 
change this. The credentials are in the file `htpasswd` in this directory, so change it to what you want.

You can use the Apache utility `htpasswd` to change the credentials, for example

	$ rm container/htpasswd
	$ htpasswd -Bbc container/htpasswd my-user my-pass

Repeat the second line to add more users.


## Change the SSL Certificate

The HTTPS Certificate & Key were generated using a private certificate authority
 and for the host name `localhost.jrcs.net` (which resolve to `127.0.0.1`). Both are stored in the file `certkey.pem`

The public key for the private CA is included as `myCA.pem`, so you can authenticate
 the private certificate, but I would recommend you change the `certkey.pem` file to use a public verifiable certificate, for example from LetEncrypt.


## Run-Time Environment Variables

When you run this container, you will need to provide it with two run-time
environment variables. They are `POWERDNS_SERVER` and `POWERDNS_KEY`, which
specify the IP Address & port of the PowerDNS Rest/API and the `api-key` you
have set in the PowerDNS config file. For example, in the file `data.env` put the lines

	POWERDNS_KEY=Dev-Key
	POWERDNS_SERVER=192.168.1.125:8081

If you're running from the command line, add the option `--env-file=data.env`. An example ENV file is in the `container.env`


## Remaking & Running the Container

The script `dkmk` will remake the container and the script `dkrun` will run it.
If you already have something listening on port 443 (HTTPS), then you can run
it with the script `dkdebug` and it will forward port `1443` into the container.
