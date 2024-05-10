

## First setup your .env file:

### Step 1. .env
fill your .env file

### Step 2. Run Install
```bash
make config
```
⚠️ Make sure domain is also configured in:
`./php-fpm.d/zz-docker.conf -> php_admin_value[sendmail_from] = server@<DOMAIN>`
`./mail/helo_access -> <DOMAIN> PERMIT`
`./ngnix/conf.d/default.conf `

### Step 3.
In Cloud Flare create a tunnel.

For your tunnel you need 3 things:
```
Public hostname      | Path        | Service
<DOMAIN>               *              https://webserver:443
www.<DOMAIN>           *              https://webserver:443
phpmyadmin..<DOMAIN>   *              http://phpmyadmin:80
```

- Get Token and Fill the details in:
`CF_TOKEN=<Cloud Flare tunel token>`

- Add an application to protect the access to phpmyadmin,
- if you do not want to protect via cloudflare phpmyadmin, make sure you remove this form docker-compose.yml in phpmyadmin. 
- This is HIGHLY discoraged to expose phpmyadmin.
```
  volumes:
      - ./wordpress/phpmyadmin/config.user.inc.php:/etc/phpmyadmin/config.user.inc.php:ro
```


### Step 4.
Generate an Edge certificate for Cloudfalre, they are user in NGNIX.
```
 ssl_certificate      conf.d/ssl/certs/cloudflare-origin.crt;
 ssl_certificate_key  conf.d/ssl/private/cloudflare-origin.key;
```

- Create an edge certificate for your domain, place those in
```
conf.d/ssl/certs/cloudflare-origin.crt;
conf.d/ssl/private/cloudflare-origin.key;
```


### Step 5.
Check you nginx content security:
`./ngnix/conf.d/default.conf`

```
add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: *.youtube.com cdnjs.cloudflare.com *.wp.com *.wp.com <DOMAIN>/* www.<DOMAIN>/*; frame-src 'self' *.youtube.com; object-src 'self'; " always;
```

### Step 6.
- Add your AWS SES Credentials, change the region if needed
```
### Emails AWS
### IAM User<setup an IAM User>
MYNETWORKS="<same as docker-compose>"
AWS_REGION_OVERRIDE=us-east-1
SES_USERNAME_PARAM=<IAM AWS ID>
SES_PASSWORD_PARAM=<IAM AWS KEY>
```

### Step 7.
- insert the DB Details
Please not `PMA_USER/PMA_PASSWRORD/PMA_DB_NAME` are user for both, Wordpress and Phpmyadmin.
```
### Database
DB_ROOT_PW=<root password>

### PHPMyAdmin/Wordpress user
PMA_USER=<wordpress db user>
PMA_PASSWORD=<wordpress db password>
PMA_DB_NAME=<wordpress db name>
```

### Step 8.
- Update your `wp-config.php`:
```
/** MySQL hostname */
define('DB_HOST', 'db:3306');
/**
 * Others, Important
 */
define('WP_SITEURL', 'https://<DOMAIN>');
define('WP_HOME', 'https://<DOMAIN>');
```

## Step 10. 
- Create the volume for the DB
`make volume`
- Start the docker
`make all`

## Step 9. Test Postfix
Connect to the docker (bash)

- SES Postfix Relay (Dockerfile)
```
sendmail -f noreply@$SES_PRIMARY_DOMAIN charlymr@mac.com
From: MyDomain Notification
Subject: Amazon SES Test                
This message was sent using Amazon SES.                
.
```
