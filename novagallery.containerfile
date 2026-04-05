FROM docker.io/opensuse/leap:15.6 AS deliverer
RUN set -eux; \
	zypper in -y wget unzip; \
	mkdir /temp; \
	wget  https://download.novafacile.com/novagallery/novagallery-free.zip; \
	unzip -d /temp novagallery-free.zip

FROM docker.io/opensuse/leap:15.6
RUN set -eux;\
	zypper refresh; \
	zypper update -y; \
	zypper in -y apache2 apache2-prefork php8 apache2-mod_php8 php8-gd php8-exif \
		php8-mbstring php8-gettext php8-openssl; \
	zypper clean -a; \
	a2enmod rewrite
COPY --from=deliverer --chown=wwwrun:www /temp/novagallery-free /var/www/novagallery-free
COPY --chmod=0755 start.sh /usr/local/bin/start.sh

WORKDIR /var/www/novagallery-free

EXPOSE 80

LABEL org.opencontainers.image.title="novagallery" \
      org.opencontainers.image.description="Unofficial openSUSE Leap based container image for novafacile/novagallery" \
      org.opencontainers.image.authors="jayhsu397" \
      org.opencontainers.image.source="https://github.com/jayhsu397/novagallery_container_image" \
      org.opencontainers.image.url="https://github.com/jayhsu397/novagallery_container_image" \
      org.opencontainers.image.documentation="https://github.com/jayhsu397/novagallery_container_image#README" \
      org.opencontainers.image.licenses="MIT AND AGPL-3.0-or-later" \
      io.github.jayhsu397.upstream.name="novafacile/novagallery" \
      io.github.jayhsu397.upstream.source="https://github.com/novafacile/novagallery"

ENTRYPOINT ["/usr/local/bin/start.sh"]
