FROM php:7.1.7-fpm

ENV NGINX_VERSION 1.13.3-1~stretch
ENV NJS_VERSION   1.13.3.0.1.11-1~stretch
# Setup webserver and process manager

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y libpcre3-dev build-essential \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt=${NGINX_VERSION} \
						nginx-module-geoip=${NGINX_VERSION} \
						nginx-module-image-filter=${NGINX_VERSION} \
						nginx-module-perl=${NGINX_VERSION} \
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
