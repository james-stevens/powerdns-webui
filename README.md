# General Disclaimer

This project has no connection whatsoever with [PowerDNS.COM BV](https://www.powerdns.com/contact.html), Open-Xchange Inc, 
The Open Group - or any other third party. It is an independently funded & maintained development effort.

# Work-in-Progress

If you want to, please do report issues you find. 
I'm always happy to fix them, but this code is still undergoing massive development change.

The basic paradigm of the UI will probably stay much as it is, but the underlying code may change.

I will try and keep the `master` branch stable (i.e. functional / usable) and do all the development in the `dev` branch.

Therefore, if you want to contribute to the development effort, please fork from the `dev` branch.
Although, my personal recommendation would be to wait until the code had stablised a lot more :)

# PowerDNS WebUI

`htdocs/index.html` is a complete self-contained, single-file, single page HTML, CSS & Javascript webapp 
to allows you to browse and edit DNS data held in a PowerDNS Database using only the PowerDNS RestAPI.

This one file is all you need in order to add a complete WebUI to your PowerDNS Server which gives you 
the ability to browse & edit all your zone & record data. This webapp has no special server-side
code, except the RestAPI that PowerDNS has built-in.

It is (currently) primarily aimed at those who are using PowerDNS as a DNS Master, as this is what I do,
but code for handling native & slave zone will probably be added later, or may just fall out in the process.
If you are using this webapp for slave & native, please let me know if there are features it needs.

`htdocs/min.html` is a minified version of the same file, minified using `python -m jsmin index.html > min.html`

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff,
particularly

* If you obtained the `index.html` over HTTPS, then the RestAPI **must** be accessed over HTTPS - this is where
using a web proxy is useful, as PowerDNS does not natively support HTTPS and sending all your data over HTTP 
is probably not what you want.

* You must be [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) - in this context it means the web server that gave you `index.html` must list
(in the header of the response) all the other HTTP/S servers you are allowed to access from the pages it has served you. 

NOTE: For CORS, "itself", is always OK by default.

These issues are generic browser security restrictions, and nothing specifically to do with this code.

We have provided a fully working example set-up in the `example` directory.

Because it accesses the PowerDNS RestAPI directly from your desktop's browser, instead of giving everybody the `api-key`,
its almost certainly safer to use a web proxy (e.g. Apache or nginx) and enforce per-user authentication in the proxy.
This means you will need to configure the proxy to add the `api-key` to each request (see below).

I used Apache. Here's a snip of my setup. It assumes your PowerDNS WebUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on port 443 (HTTPS). The PowerDNS IP Address will probably work for you.  

I haven't included the SSL or per-user authentication config lines, you will need to add whatever you prefer, 
but all the SSL & Basic Authentication configuration is included in `example/httpd.conf`.

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

You will need to ensure you have loaded the Apache proxy modules, I used these

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

I've tested this with the latest Chrome & Firefox running on Xubuntu talking to a 95% idle PowerDNS server 
running v4.2.0 over an 18ms latency link and the response time for all actions, including loading a zone with 1000 records
(500 names, 2 records per name), is virtually instant.

Apart from some minor aesthetic differences, the behaviour in Chrome and Firefox was identical.


# Security #

There are deliberatly **NO** security options in this webapp, e.g. who can edit/delete zones/names/records etc.

When you have a JavaScript/RestAPI application the place to put the security is in the server-side RestAPI. 
Any security put into the Javascript can probably be trivially circumvented and is therefore of extremely limited value.

In various web proxies, there are options to block certain `METHOD`. For exmaple, by blocking all `METHOD` except `GET`, 
you can stop a user from being able to do updates. For more information, please ask Google.
