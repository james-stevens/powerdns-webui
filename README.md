# PowerDNS WebUI

`index.html` provides a single-file, single page HTML, CSS & Javascript application to allow you to browse and edit 
DNS data held in a PowerDNS Database using the PowerDNS RestAPI.

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff.
Particularly [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

Because it accesses the PowerDNS RestAPI directly from your browser, rather than giving everybody the `api-key`
its almost certainly safer to use a web proxy (e.g. Apache or nginx) and enforce per-user authentication in the proxy.

I used Apache - here's a suitable setup. It assumes your PowerDNS WebUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on 192.168.1.126 (this will be host dependant, of course).

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

