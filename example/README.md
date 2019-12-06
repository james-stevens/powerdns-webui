# Example Setup #

This is intended to be the simplest example set-up you could use with PowerDNS and Apache to get
this single-page WebUI working.

This is not intended as a tutorial or guide to best practice on Apache, Apache-SSL/TLS, PowerDNS or Let-Encrypt - for that, please use Google.

This set up assumes you have Apache installed in `/usr/local/apache2` and you have your Lets-Encrypt key & certs
in `/opt/daemon/keys/letsencrypt` and you are using `/opt/pid` as the Apache PID & cgi-sock directory. If
any of these don't match what you want. please change the settings in `httpd.conf`.

With this project installed as `/opt/websites/pdns/powerdns-webui`, run the following

$ sudo httpd -f /opt/websites/pdns/powerdns-webui/example/httpd.conf
$ sudo pdns_server --config-dir=/opt/websites/pdns/powerdns-webui/example

then point your browser to `https://<this-servers-ip>/`

*Usernanme: `dns`
*Password: `dns`
