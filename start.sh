#!/bin/bash
#maintainer:jayhsu397(jayhsu397@gmail.com)
#Unofficial container image for novafacile/novagallery
#Powered by novafacile OÜ

set -euo pipefail

SERVER_NAME="${SERVER_NAME:-127.0.0.1}"
URL="${URL:-http://127.0.0.1:8000}"
ADDONS_PRIVATE_MODE_ENABLE="${ADDONS_PRIVATE_MODE_ENABLE:-false}"
ADDONS_PRIVATE_MODE_ENABLE="${ADDONS_PRIVATE_MODE_ENABLE,,}"
ADDONS_ROBOTS_META_TAG_ENABLE="${ADDONS_ROBOTS_META_TAG_ENABLE:-false}"
ADDONS_ROBOTS_META_TAG_ENABLE="${ADDONS_ROBOTS_META_TAG_ENABLE,,}"
ADDONS_ROBOTS_META_TAG_ALLOW_INDEX="${ADDONS_ROBOTS_META_TAG_ALLOW_INDEX:-false}"
ADDONS_ROBOTS_META_TAG_ALLOW_INDEX="${ADDONS_ROBOTS_META_TAG_ALLOW_INDEX,,}"
ADDONS_NOVAGALLERY_PRO_ENABLE="${ADDONS_NOVAGALLERY_PRO_ENABLE:-false}"
ADDONS_NOVAGALLERY_PRO_ENABLE="${ADDONS_NOVAGALLERY_PRO_ENABLE,,}"
PASSWORD_HASH=""

# Generating site.php
if [[ ! -s /var/www/novagallery-free/config/site.php ]]; then
	echo 'Generating site.php...'
	cp /var/www/novagallery-free/config/site.example.php /var/www/novagallery-free/config/site.php
	sed -i "s#https://demo.novagallery.org#${URL}#g" /var/www/novagallery-free/config/site.php
else
	echo 'Skipping site.php generation'
fi

# Generating vhost configuration
if compgen -G "/etc/apache2/vhosts.d/*.conf" >/dev/null; then
	echo "Vhost configuration file exists, skipping vhost generation..."
else
	echo 'Generating vhost configuration file...'
	cat <<EOF >/etc/apache2/vhosts.d/default_000.conf
<VirtualHost *:80>
    ServerName ${SERVER_NAME}
    DocumentRoot /var/www/novagallery-free

    <Directory /var/www/novagallery-free>
        AllowOverride All
        Options FollowSymLinks
        Require all granted
    </Directory>

    DirectoryIndex index.php index.html
</VirtualHost>
EOF
fi

# Checking if PASSWORD exists when needed
if [[ "${ADDONS_PRIVATE_MODE_ENABLE}" == "true" && ! -s /var/www/novagallery-free/config/addons.php ]]; then
	echo 'Checking if PASSWORD exists...'
	PASSWORD="${PASSWORD?Please set your password when ADDONS_PRIVATE_MODE_ENABLE == true}"
else
	echo 'Skipping PASSWORD check'
fi

# Generating password hash when needed
if [[ "${ADDONS_PRIVATE_MODE_ENABLE}" == "true" && "${PASSWORD_HASH}" == "" && ! -s /var/www/novagallery-free/config/addons.php ]]; then
	# Generate PASSWORD_HASH according to the value of PASSWORD
	echo 'Generating password hash...'
	PASSWORD_HASH="$(PASSWORD="${PASSWORD}" \
		php -r 'echo password_hash(getenv("PASSWORD"), PASSWORD_DEFAULT);')"
else
	echo 'Skipping password hash generation'
fi

# Generating addons.php
if [[ ! -s /var/www/novagallery-free/config/addons.php ]]; then
	echo 'Generating addons.php...'
	cat <<EOF >/var/www/novagallery-free/config/addons.php
<?php defined("NOVA") or die(); ?>
{
  "Password Protection": {
    "enabled": ${ADDONS_PRIVATE_MODE_ENABLE},
    "passwordHash": "${PASSWORD_HASH}"
  },
  "Robots Meta Tag": {
    "enabled": ${ADDONS_ROBOTS_META_TAG_ENABLE},
    "allowIndex": ${ADDONS_ROBOTS_META_TAG_ALLOW_INDEX}
  },
  "novaGallery Pro": {
    "enabled": ${ADDONS_NOVAGALLERY_PRO_ENABLE},
    "licenseKey": ""
  }
}
EOF
else
	echo 'Skipping addons.php generation'
fi

# Prepare and start apache2
chown -R wwwrun:www /var/www/novagallery-free/storage
echo 'ServerName localhost' >>/etc/apache2/httpd.conf #Surpressing apache2 warning

echo 'Starting apache2...'
exec start_apache2 -DFOREGROUND
# This is an openSUSE Leap based image, which uses start_apache2 instead of apache2ctl.
