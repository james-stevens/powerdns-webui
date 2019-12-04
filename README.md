# PowerDNS WebUI

"index.html" provides a single-file, single page Javascript application to allow you to browse and edit 
DNS data held in a PowerDNS Database using the PowerDNS RestAPI.

Its super simple to use, but does require a little setting up to ensure your browser is happy with stuff.
Particularly [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

Because it access the PowerDNS RestAPI directly from your browser, rather than giving everybody the PSK
its almost certainly safer to use a web server proxy and enforce per-user authentication in the proxy.

I used Apache - here's a suptable setup, assuming your PowerDNS webUI is listening on IP Address 127.1.0.1
and your Apache Server can listen on 192.168.1.126

The PowerDNS IP Address is probably fine for you, but you will need to change the Apache IP Address to match
what your server is using. You will also need all the SSL configuration lines to set up the private key & certificate, etc.

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
