FROM php:7.1.7-fpm

ENV NGINX_VERSION 1.12.1-1
ENV NJS_VERSION   1.12.1.0.1.10-1

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y gnupg1 \
	&& \
	NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
	found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
	apt-get -y --purge autoremove && rm -rf /var/lib/apt/lists/* \
	&& echo "deb http://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt=${NGINX_VERSION} \
						nginx-module-geoip=${NGINX_VERSION} \
						nginx-module-image-filter=${NGINX_VERSION} \
						nginx-module-njs=${NJS_VERSION} \
						gettext-base \
						supervisor \
						openssh-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo "root:Docker!" | chpasswd

# forward request and error logs to docker log collector
RUN mkdir -p /home/LogFiles/docker \
	&& ln -sf /dev/stdout /home/LogFiles/docker/access.log \
	&& ln -sf /dev/stderr /home/LogFiles/docker/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf	
COPY sshd_config /etc/ssh/
COPY init_container.sh /bin/

RUN chmod 755 /bin/init_container.sh
  
EXPOSE 80 2222

CMD ["/bin/init_container.sh"]
