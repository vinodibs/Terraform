#!/bin/bash
sudo apt-get update -y
sudo apt-get install curl -y
sudo apt-get install apache2 apache2-utils  -y
sudo apt-get install php7.0 php7.0-* libapache2-mod-php7.0 -y
cat >> /var/www/html/info.php <<-EOF
<?php 
phpinfo();
?>
EOF
cd /tmp
sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/ /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sed  '/WP_DEBUG/a define('WP_ALLOW_MULTISITE', true); ' /var/www/html/wordpress/wp-config.php > tmp && mv tmp /var/www/html/wordpress/wp-config.php
#sudo sed -i '81 s/^/define('WP_ALLOW_MULTISITE', true);/' /var/www/html/wordpress/wp-config.php
sudo sed '/CustomLog/a <Directory /var/www/>\nOptions Indexes FollowSymLinks MultiViews\nAllowOverride All\nOrder allow,deny\nallow from all\n</Directory>' /etc/apache2/sites-enabled/000-default.conf
sudo a2enmod rewrite
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp plugin update --all
sudo systemctl restart apache2
sudo systemctl enable apache2
