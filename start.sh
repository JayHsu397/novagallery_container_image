#!/bin/bash
#maintainer:jayhsu397(jayhsu397@gmail.com)
#Unofficial container image for novafacile/novagallery
#Powered by novafacile OÜ

set -euo pipefail

SERVER_NAME="${SERVER_NAME:-127.0.0.1}"
URL="${URL:-http://127.0.0.1:8000}"

if [[ ! -s /var/www/novagallery-free/config/site.php ]]; then
	cp /var/www/novagallery-free/config/site.example.php /var/www/novagallery-free/config/site.php
	sed -i "s#https://demo.novagallery.org#${URL}#g" /var/www/novagallery-free/config/site.php
fi

if compgen -G "/etc/apache2/vhosts.d/*.conf" >/dev/null; then
	echo "Vhost configuration file exists ,skipping vhost generation..."
else
	echo "Generating default configuration file..."
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

chown -R wwwrun:www /var/www/novagallery-free/storage
exec start_apache2 -DFOREGROUND
# This is an openSUSE Leap based image, which uses start_apache2 instead of apache2ctl.
