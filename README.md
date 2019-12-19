# General Disclaimer

This project has no connection whatsoever with [PowerDNS.COM BV](https://www.powerdns.com/contact.html),
[Open-Xchange Inc](https://www.open-xchange.com/) - or any other third party.

It is an independently funded & maintained development effort.

# Status

The main thrust of this development is now complete - I think :)

This is a summary of the features this WebUI provides to PowerDNS

* Servers - contact PowerDNS Servers directly or though a web proxy, HTTP or HTTPS (see below)
* Zones - Add, View, Remove, Sign, Unsign, Force NOTIFY, Rectify, Download in RFC format, force update (slave only)
* Metadata - Add, Edit, Remove Metadata items or individual values, with some local validation
* Hosts/names - Master or Native only - Add, Edit, Remove RRs / RR-Sets with some local validation
* TSIG Keys - Add, Regenerate, Remove, copy name or key to clipboard
* DNSSEC
	* Sign an unsigned zone - NSEC or NSEC3, KSK+ZSK or CSK, any algorythm & key lengths
	* Unsign a signed zone
	* Step-by-Step one-button CSK, KSK or ZSK key roll-over
	* Add, remove, activate / deactivate individual keys
	* DS digest, auto-copy-to-clipboard
	* Convert NSEC to NSEC3 or vice versa
	* NSEC3PARAM roll-over


# PowerDNS WebUI

`htdocs/index.html` is a complete self-contained, single-file, single page HTML, CSS & Javascript webapp
to allows you to browse and edit DNS data held in a PowerDNS Database using only the PowerDNS RestAPI.

You can clone the project, if you want, but this one file is all you need in order to add a complete WebUI to your PowerDNS Server.
This gives you the ability to browse & edit all your zone & record data. This webapp has no special serverside
code, except the RestAPI that PowerDNS has built-in.

It is (currently) primarily aimed at those who are using PowerDNS as a DNS Master, as this is what I do,
but code for handling native & slave zone will probably be added later, or may just fall out in the process.
If you are using this webapp for slave & native, please let me know if there are features it needs.

`htdocs/min.html` is a minified version of the same file, minified using `python -m jsmin index.html > min.html`

# Browser Security Restrictions

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff.
These issues are generic browser security restrictions, and nothing specifically to do with this code.

* If your browser received the `index.html` over HTTPS, then the RestAPI **must** be accessed over HTTPS - this is where
using an HTTP/HTTPS proxy is useful, as PowerDNS does not natively support HTTPS and sending all your data over HTTP
is probably not what you want.

* You must be [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) compliant - in this context it means the web server
that gave your browser `index.html` must list (in the header of the response) all the other HTTP/S servers you are allowed to access from the pages it has served you.

NOTE: For CORS, by default, you are allowed to access the Rest/API on the server that sent you the `index.html`.
So this requires no special extra consideration.


# The Example Config

We have provided a fully working example set-up in the `example` directory.

Because this webapp accesses the PowerDNS RestAPI directly from your desktop's browser, to prevent you having to give everybody the `api-key`,
we would recommend you use a web proxy (e.g. Apache or nginx) and enforce per-user authentication in the proxy.
This means you will need to configure the proxy to add the `api-key` to each request (see below).

You can also use the web proxy to provide an HTTP->HTTPS service.

I used Apache. Here's a snip of my setup. It assumes your PowerDNS WebUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on port 443 (HTTPS). The PowerDNS IP Address will probably work for you.

I haven't included the SSL, or per-user authentication, config lines, you will need to add whatever you prefer,
but all the SSL & Basic Authentication configuration is included in `example/httpd.conf` and `exmaple/nginx.conf`.

```
<VirtualHost *:443>

	DocumentRoot /opt/websites/pdns/powerdns-webui/htdocs

	<Proxy http://127.1.0.1:8081/*>
		Allow from all
	</Proxy>

    <location /stats/>
        ProxyPass http://admin,Dev-Key@127.1.0.1:8081/
        ProxyPassReverse http://admin,Dev-Key@127.1.0.1:8081/
    </location>

	<location /api>
		Header add X-API-Key "Dev-Key"
		RequestHeader set X-API-Key "Dev-Key"
		ProxyPass http://127.1.0.1:8081/api
		ProxyPassReverse http://127.1.0.1:8081/api
	</location>

</VirtualHost>
```

Becuase I want the webapp to live in the ROOT directory of the website, this overloads the PowerDNS stats page (which also lives at the root),
so I have put in a rule that makes the stats page available from `https://<server-ip-address>/stats/`

You will need to ensure you have loaded the Apache proxy modules, I used this code

```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule rewrite_module  modules/mod_rewrite.so
```
Here's the corresponding PowerDNS `pdns.conf` settings for the WebUI & Rest-API

```
...

webserver=yes
webserver-address=127.1.0.1
webserver-allow-from=127.0.0.0/8
webserver-password=Dev-Key
api=yes
api-key=Dev-Key

...

```


Clone this project as the directory `/opt/websites/pdns/powerdns-webui`,
or whatever you chose in the Apache conf, and request the URL `https://<server-ip-address>/`

If it worked correctly, you should see a screen like this.

![Frist Screen](/first.png)

Because it prompts you for a server name, you can use this single page app to access any PowerDNS RestAPI
you can reach, subject to the browser restrictions described above.

A fully working example configuration, and instructions, are provided in the `example` directory.


# In Operation #

I've tested this with the latest Chrome & Firefox running on Xubuntu (Ubuntu + XFCE) talking to a 95% idle PowerDNS server
running v4.2.0 over an 18ms latency link and the response time for all actions, including loading a zone with 1000 records
(500 names, 2 records per name), is virtually instant.

Apart from some minor aesthetic differences, the behaviour in Chrome and Firefox was identical.

nginx performed the same as Apache - virtually instant.


# Security #

This webapp is intended as a SysAdmin aid, and not to be given directly to end-users without the addition of more serverside security.
Especially, this webapp is not recommended in the situation where you have multiple users owning different domains.

There are deliberatly **NO** security options in this webapp, e.g. who can edit/delete zones/names/records etc.

As a general principal, when you have a JavaScript+RestAPI webapp the place to put the security is in the serverside RestAPI.
Any security put into the Javascript can probably be trivially circumvented and is therefore of extremely limited value.

In various web proxies, there are options to block certain `METHODs`. For example, by blocking all `METHODs` except `GET`,
you can stop a user from being able to do updates. For more information, please ask Google.

In general, therefore, as it is provided, this webapp is probably not going to be that useful for giving to end users.
However, as an admin-tool, it can be very useful.
