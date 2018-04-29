# nsd-dyndns

## Introduction

nsd-dyndns is a simple script that adds dynamic DNS dunctionality to NSD (authoritative DNS name server).

## Requirements

The following is required or suggested:

  * OpenBSD (or another BSD or some Linux distro) with HTTPD and NSD installed (pkg_add nsd), configured and running
  * (sub-)domain for your webserver. Needed for updating the NS record of your actual DynDNS domain.
    * In this example: update.example.com
  * (sub-)domain that is updated dynamically. 
    * In this example: dyn.example.com
  * A router capable of sending custom GET-requests to your DynDNS server.
    * In this example: A FritzBox
 
 ## Installation
 
 ### Configure your HTTPD
 
 Add the following new virtual host to your /etc/httpd.conf:
 
```
 server "update.example.com" {
        listen on $ext_addr port 80
        root "/htdocs/dyndns"
        log access dyndns.log
}
```
 
Create an empty index.html:
 
```
# mkdir /var/www/htdocs/dyndns/
# touch /var/www/htdocs/dyndns/update.html
```

After reloading HTTPD, try to access http://update.example.com/update.html
The request should show up in /var/www/logs/dyndns.log

### Create a zone file for dyn.example.com

Create a new zone file (e.g. at /var/nsd/zones/dyn.example.com.zone) with the following content

```
$ORIGIN example.com.
$TTL 300
@       IN      SOA     ns1.example.com.      admin.example.com. (
1524952218
                        300                     ; refresh
                        900                     ; retry
                        1209600                 ; expire
                        1800                    ; ttl
                        )
; Name servers
                    IN      NS      ns1.example.com.
                    IN      NS      ns1.example.com.

; A records
@ IN A 123.123.123.123
update IN A 123.123.123.123
dyn IN A 123.123.123.13
```

Don't forget to set your own domain names, name servers and ip addresses
Furthermore, add this zone file to your /var/nsd/etc/nsd.conf

### Configure and Install nsd-dyndns

  * Copy _dyndns.conf-dist_ to _/etc/dyndns.conf_
  * Edit _/etc/dyndns.conf_ to your needs
  * Copy _dyndns.sh_ to _/usr/local/bin/dyndns.sh_
  * Make the script executable:
    * _# chmod u+x /usr/local/bin/dyndns.sh_
  * Add _/usr/local/bin/dyndns.sh_ to your crontab
  
```
 
```




```
 
```




```
 
```



```
 
```
