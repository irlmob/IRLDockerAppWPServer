## First setup your .env file:

### Step 1. .env

```
COMPOSE_PROJECT_NAME=<name>-web
NAME=<name>

## Domains
SES_PRIMARY_DOMAIN=<DOMAIN>
SES_MYHOSTNAME=$SES_PRIMARY_DOMAIN
HTML_SITE_PATH=/var/www/html/

### Database
DB_ROOT_PW=<root password>
MARIADB_ROOT_PASSWORD=$DB_ROOT_PW
MYSQL_ROOT_PASSWORD=$DB_ROOT_PW

### Emails AWS
### IAM User<setup an IAM User>
MYNETWORKS="<same as docker-compose>"
AWS_REGION_OVERRIDE=us-east-1
SES_USERNAME_PARAM=<IAM AWS ID>
SES_PASSWORD_PARAM=<IAM AWS KEY>

### PHPMyAdmin
PMA_USER=<wordpress db user>
PMA_PASSWORD=<wordpress db password>
PMA_DB_NAME=<wordpress db name>


## Cron Job / Backup 
# DB Name is the same as docker compose
DBNAME=${NAME}-mariadb 
RESTIC_PASSWORD=<restic password>

### CloudFlare Zerotrust Token
CF_TOKEN=<Cloud Flare tunel token>
```
### Step 2. Run Install

## ⚠️ Make sure domain is also configured in:
## ./php-fpm.d/zz-docker.conf -> php_admin_value[sendmail_from] = server@<DOMAIN>
## ./mail/helo_access -> <DOMAIN> PERMIT
## ./ngnix/conf.d/default.conf 

### Step 3.
In Cloud Flare create a tunnel
Add your public hosts
(optionnal protect phpmyadmin, coudl be phpmyadmin.<DOMAIN>)

### Step 4.
Validate and edit thos:
## ./php-fpm.d/zz-docker.conf -> php_admin_value[sendmail_from] = server@<DOMAIN>
## ./mail/helo_access -> <DOMAIN> PERMIT
## ./ngnix/conf.d/default.conf 

### Step 5.
Update your wp-config.php:
```
/** MySQL hostname */
define('DB_HOST', 'db:3306');

/**
 * Others, Important
 */
define('WP_SITEURL', 'https://<DOMAIN>');

define('WP_HOME', 'https://<DOMAIN>');

```

### Step 6.
Check you nginx content security:
`./ngnix/conf.d/default.conf`

```
        add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: *.youtube.com cdnjs.cloudflare.com *.wp.com *.wp.com <DOMAIN>/* www.<DOMAIN>/*; frame-src 'self' *.youtube.com; object-src 'self'; " always;
```

## Step 7. Test Postfix
Connect to the docker (bash)
# SES Postfix Relay (Dockerfile)

## To Test
sendmail -f noreply@$SES_PRIMARY_DOMAIN charlymr@mac.com
From: MyDomain Notification
Subject: Amazon SES Test                
This message was sent using Amazon SES.                
.


### Step 8. (Optional)
Generate an Edge certificate for Cloudfalre
```
        ssl_certificate      conf.d/ssl/certs/cloudflare-origin.crt;
        ssl_certificate_key  conf.d/ssl/private/cloudflare-origin.key;
```
