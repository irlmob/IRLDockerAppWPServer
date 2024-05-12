# IRLDockerAppWPServer - All In Word Wordpress/Nginx/SES/CloudFlare/Backup

### Overview

IRLDockerAppWPServer is a comprehensive Docker-based project designed to set up a WordPress environment using Nginx, integrated with several other services such as Amazon SES for email delivery, CloudFlare for DNS and security enhancements, and automated backup solutions. The system is tailored for deployment on Linux distributions and leverages Docker for containerization, ensuring a consistent environment across different systems.

### Purpose

The primary purpose of the IRLDockerAppWPServer is to provide users with a robust, scalable, and secure platform for hosting WordPress sites. 

This setup aims to simplify the configuration processes associated with complex WordPress deployments, integrating essential services such as secure email delivery, SSL/TLS management, and database administration. By automating many of the setup steps, 

it allows users to quickly deploy and manage WordPress sites with enhanced security features and performance optimizations.

### Key Features and Steps

1. **Environment Setup**: Users begin by cloning the repository and setting up the `.env` file which configures the environment variables necessary for the different components of the stack.
2. **Integration with CloudFlare**: This includes setting up a tunnel for secure connectivity and configuring DNS settings to ensure the site is accessible and secure.
3. **Email Configuration**: The system integrates with Amazon SES for email functionality, requiring users to input their AWS credentials and configure email settings in Nginx.
4. **Security Measures**: It includes steps for generating CloudFlare edge certificates and configuring content security policies in Nginx to enhance security.
5. **Database Management**: Users configure database access for both WordPress and phpMyAdmin, ensuring that database credentials are securely handled and correctly linked to the respective services.
6. **WordPress Configuration**: Adjustments to `wp-config.php` ensure that WordPress recognizes the correct site URL and database settings.
7. **Operational Commands**: The setup includes `make` commands for managing Docker containers, such as creating volumes and starting the server.
8. **Testing and Deployment**: Final steps involve testing the email system with Amazon SES and starting the entire Docker setup to go live.

This Docker setup is especially beneficial for developers and administrators looking to deploy WordPress sites efficiently with a focus on security and performance, without the need for extensive manual configuration.

## Prerequisites
- **Docker**: Docker must be install on the machine.
- **Make**: Required to execute the make commands.
  - Install Make: `apt-get install build-essential`
- **Linux distributions ONLY**:

## First setup your .env file:

### Step 1. .env

Clone the repo in your folder
`git clone https://github.com/irlmob/IRLDockerAppWPServer.git`

`cp env.template .env`

### Step 2. Run Install
```bash
make config
```

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
      - ./configs/phpmyadmin/config.user.inc.php:/etc/phpmyadmin/config.user.inc.php:ro
```


### Step 4.
Generate an Edge certificate for Cloudfalre, they are user in nginx.
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
`./configs/nginx/conf.d/default.conf`

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

### PHPMyAdmin/configs user
PMA_USER=<wordpress db user>
PMA_PASSWORD=<wordpress db password>
PMA_DB_NAME=<wordpress db name>
```

### SCP form a server.

```
scp -r teleport/sardirlmobcom-web/ root@vpsovh:/root/apps/
scp -r root@vpsovh:/var/www/sardirlmobcom ./html
scp root@vpsovh:/root/docker/irlmobile-mariadb/share/dump/latest.sql.gz configs/database/latest.sql.gz
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
