# nsd-dyndns

## Introduction

nsd-dyndns is a simple script that adds dynamic DNS dunctionality to NSD (authoritative DNS name server).

## Requirements

The following is required or suggested:

  * OpenBSD (or another BSD or some Linux distro) with HTTPD and NSD installed (pkg_add nsd), configured and running
  * (sub-)domain for your webserver. Needed for updating the NS record of your actual DynDNS domain.
    * In this example: _update.example.com_
  * (sub-)domain that is updated dynamically. 
    * In this example: _dyn.example.com_
  * A router capable of sending custom GET-requests to your DynDNS server.
    * In this example: A FritzBox
 
 ## Installation
 
 ### Configure your HTTPD
 
 Add the following new virtual host to your _/etc/httpd.conf_:
 
```
 server "update.example.com" {
        listen on $ext_addr port 80
        root "/htdocs/dyndns"
        log access dyndns.log
}
```
 
Create an empty _update.html_:
 
```
# mkdir /var/www/htdocs/dyndns/
# touch /var/www/htdocs/dyndns/update.html
```

After reloading HTTPD, try to access http://update.example.com/update.html
The request should show up in _/var/www/logs/dyndns.log_

### Create a zone file for dyn.example.com

Create a new zone file (e.g. at _/var/nsd/zones/dyn.example.com.zone_) with the following content

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
Furthermore, add this zone file to your _/var/nsd/etc/nsd.conf_

### Configure and Install nsd-dyndns

  * Copy _dyndns.conf-dist_ to _/etc/dyndns.conf_
    * _# cp dyndns.conf-dist /etc/dyndns.conf_
  * Edit _/etc/dyndns.conf_ to your needs
  * Copy _dyndns.sh_ to _/usr/local/bin/dyndns.sh_
    * _# cp dyndns.sh /usr/local/bin/dyndns.sh_
  * Make the script executable:
    * _# chmod u+x /usr/local/bin/dyndns.sh_
  * Add _/usr/local/bin/dyndns.sh_ to your crontab

### Configure your router

Configure your router to query the following URL:

```
update.example.com/update.html?qwertzuiop1234567890
```

Don't forgert to set your own domain name and to replace the string after "?" with the password you configured in the config file.

### What it does

When your router gets a new IP and therefore sends an HTTP request to your server, a similar entry should appear in your _/var/www/logs/dyndns.log_:

```
update.axample.com 123.123.123.123 - - [29/Apr/2018:20:48:19 +0200] "GET /update.html?qwertzuiop1234567890 HTTP/1.1" 200 6
```

When the script is executed e.g. via cron, the following happens:
  * It greps the last line of _/var/www/logs/dyndns.log_ where the correct password was found and extracts the requesting IP address
  * It checks if this IP is the same than the last time
  * If it's a new IP, then it replaces the forth line in your zone file - the line with the version number - with a new version (current unix time stamp)
  * As a second step, it updates the A record of you DynDNS domain (dyn.example.com in our example)
  * It then stores the new IP in the file _/tmp/last_dyndns_ip.txt_
  * Finally it reloads NSD
