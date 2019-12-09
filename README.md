# PowerDNS WebUI ---- Still Work-in-Progress

`htdocs/index.html` is a complete self-contained, single-file, single page HTML, CSS & Javascript application 
to allows you to browse and edit DNS data held in a PowerDNS Database using only the PowerDNS RestAPI.

`htdocs/min.html` is a minified version of the same file, minified using `python -m jsmin index.html > min.html`

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff,
particularly [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS), 
so we have provided a fully working example set-up in the `example` directory.

Because it accesses the PowerDNS RestAPI directly from your desktop's browser, instead of giving everybody the `api-key`,
its almost certainly safer to use a web proxy (e.g. Apache or nginx) and enforce per-user authentication in the proxy.
This means you will need to configure the proxy to add the `api-key` to each request (see below).

I used Apache. Here's a snip of a suitable setup. It assumes your PowerDNS WebUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on port 443 (HTTPS).

Below, I haven't included the SSL or per-user authentication config lines, you will need to add whatever you prefer, 
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

Becuase I want the Web-App to live in the ROOT directory of the webs site, this overloads the PowerDNS stats page, so I have
put in a rule that makes the stats page available from `https://<server-ip-address>/stats/`

The PowerDNS IP Address will probably work for you.

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


Then you simply clone this project as the directory `/opt/websites/pdns/powerdns-webui`,
or whatever you chose in the Apache conf, and request the URL `https://<server-ip-address>/`

If it worked correctly, you should see a screen like this.

![Frist Screen](/first.png)


NOTE: Because it prompts you for a server name, you can use this single page app to access any PowerDNS RestAPI
you can reach, but your browser will impose certain restrictions.

* If you obtained the `index.html` over HTTPS, then the RestAPI must be accessed over HTTPS - this is where
a web proxy interface is useful, as PowerDNS does not natively support HTTPS and sending all your
data over HTTP is probably not what you want.

* You must be CORS compliant - in this context it means the web server that gave you `index.html` must list
(in the header of the response) all the other HTTP/S servers
you are allowed to access from the pages it has served you. 

Having the page served from the same service as the web proxy to the api, provides a solution to both these issue.

These issues are generic browser security restrictions, and nothing specifically to do with this code.

A fully working example configuration, and instructions, are provided in the `example` directory.


# In Operation #

I've tested this talking to a 95% idle PowerDNS server over an 18ms latency link and the response time for 
loading a zone with 1000 records (500 names, 2 records per name) is virtually instant.
