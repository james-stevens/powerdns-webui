# PowerDNS WebUI

`index.html` is a complete self-contained, single-file, single page HTML, CSS & Javascript application 
to allows you to browse and edit DNS data held in a PowerDNS Database using the PowerDNS RestAPI.

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff.
Particularly [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

Because it accesses the PowerDNS RestAPI directly from your browser, rather than giving everybody the `api-key`
its almost certainly safer to use a web proxy (e.g. Apache or nginx) and enforce per-user authentication in the proxy.

I used Apache - here's a suitable setup. It assumes your PowerDNS WebUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on 192.168.1.126 (this will be host dependant, of course).

I haven't included the per-user authentication config lines, you will need to add whatever you prefer.

```
<VirtualHost 192.168.1.126:443>

	DocumentRoot /opt/websites/pdns/powerdns-webui

	<Proxy http://127.1.0.1:8081/*>
		Allow from all
	</Proxy>

	<location /api>
		Header add X-API-Key "Dev-Key"
		RequestHeader set X-API-Key "Dev-Key"
		ProxyPass http://127.1.0.1:8081/api
		ProxyPassReverse http://127.1.0.1:8081/api
	</location>

</VirtualHost>
```

The PowerDNS IP Address is probably fine for you, but you will need to change the Apache IP Address to match
what your host server is using. 
You will need additional SSL configuration lines to set up the private key & certificate, etc.

You will need to ensure you have loaded the Apache proxy modules, I used these

```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule rewrite_module  modules/mod_rewrite.so
```
Here's the corresponding PowerDNS `pdns.conf` settings for the WebUI

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


then you simply place the `index.html` from this project into the directory `/opt/websites/pdns/powerdns-webui`,
or whatever you chose in the Apache conf, and request the URL `https://192.168.1.126/`

If it worked correctly, you should see a screen like this.

![Frist Screen](/first.png)


NOTE: you can use this single page app to access any PowerDNS RestAPI, but your browser will impose certain
restrictions.

* If you obtained the `index.html` over HTTPS, then the RestAPI must be accessed over HTTPS - this is where
a web proxy interface is useful, as PowerDNS does not natively support HTTPS

* You must be CORS compliant - this means the web server that gave you the page must list all the other web servers
you are allowed to access from the pages it has served you. Again, this is where having the page served from the
same site as the web proxy to the api provides a solution to this issue.

These issues are generic browser security restrictions, and nothing specifically to do with this code.
