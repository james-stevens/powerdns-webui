# Example Setup #

This is intended to be the simplest example set-up you could use, with PowerDNS & Apache / nginx, to get
this single-page webapp working.

This is not intended as a tutorial or guide to best practice on Apache, nginx, Apache-SSL/TLS, PowerDNS or Lets-Encrypt - for that, please use Google.

This set up assumes 
* You have installed this project in `/opt/websites/pdns/powerdns-webui`
* You have Apache installed in `/usr/local/apache2` 
* You have your Lets-Encrypt key & certs in `/opt/daemon/keys/letsencrypt` 
* You are using `/opt/pid` as the Apache PID & cgi-sock directory. 

Then copy the password file to the Apache `conf` directory

```
$ sudo cp example/passwd /usr/local/apache2/conf/passwd
```

If any of these don't match what you want, just change the settings in `httpd.conf`.

With this project cloned to `/opt/websites/pdns/powerdns-webui`, run the following

```
$ sudo httpd -f /opt/websites/pdns/powerdns-webui/example/httpd.conf
$ sudo pdns_server --config-dir=/opt/websites/pdns/powerdns-webui/example
```

then point your browser to `https://<this-servers-ip>/`

* Username: `dns`
* Password: `dns`

To replace the username & password, use the following

```
htpasswd -bcB /opt/websites/pdns/powerdns-webui/example/passwd [user] [pass]
```

I have also included an example config for `nginx` -> `nginx.conf`. The easiest way to get this 
working is to copy it into your `nginx/conf` directory. You might want to make a copy of the existing one first.

On my platform, nginx would not support `bcrypt` encrypted passwords. In the browser I got an `Internal Server Error` and 
`crypt_r() failed (22: Invalid argument)` in the `error.log`, so you would need to 
repalce the password with one that is MD5 (yuck) encrypted. You can do this by dropping the `B`
option from the `htpasswd` command.

I found this bug documented [here](https://github.com/kubernetes/ingress-nginx/issues/3150).

I also copied the Lets-Ecrypts files into the nginx `conf` directory

* `letsencrypt/privkey.pem` -> `nginx/conf/cert.key`
* `letsencrypt/cert.pem` -> `nginx/conf/cert.pem`


