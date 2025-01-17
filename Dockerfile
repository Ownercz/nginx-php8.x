FROM ubuntu:22.04

LABEL maintainer="radim@lipovcan.cz"

# Let the container know that there is no tty
ENV DEBIAN_FRONTEN noninteractive
RUN apt-get update  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install postfix
RUN dpkg-divert --local --rename --add /sbin/initctl && \
	ln -sf /bin/true /sbin/initctl && \
	mkdir /var/run/sshd && \
	mkdir /run/php && \
	apt-get update && \
	apt-get install -y --no-install-recommends apt-utils \ 
	gpg-agent \ 
	software-properties-common \
	language-pack-en-base && \
	LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
	apt-get update && \
	apt-get install -y python-setuptools \ 
	curl \
	git \
	nano \
	sudo \
	unzip \
	openssh-server \
	openssl \
	supervisor \
	nginx \
	memcached \
	iputils-ping \
	cron && \
	# Install PHP
	apt-get install -y php8.1-fpm \
	php8.1-mysql \
	php8.1-curl \
	php8.1-gd \
	php8.1-intl \
	php-memcache \
	php8.1-sqlite \
	php8.1-tidy \
	php8.1-pgsql \
	php8.1-ldap \
	freetds-common \
	php8.1-pgsql \
	php8.1-sqlite3 \
	php8.1-xml \
	php8.1-mbstring \
	php8.1-soap \
	php8.1-zip \
	php8.1-cli \
	php8.1-sybase \
	php8.1-xdebug \
	php8.1-odbc \
	php8.1-imagick \
	php8.1-redis \
	php8.1-bcmath
 
 RUN apt-get install nano python3 python3-pip python3-yaml nginx php8.1 php8.1-fpm php8.1-cli php8.1-common php8.1-curl php8.1-phpdbg php8.1-gd php8.1-odbc php8.1-pgsql php8.1-mbstring php8.1-mysql php8.1-xmlrpc php8.1-opcache php8.1-intl php8.1-bz2 php8.1-xml php8.1-imagick php8.1-pspell php8.1-imap php8.1-gd php8.1-curl php8.1-xmlrpc php8.1-mysql php8.1-cgi php8.1-fpm php8.1-dev php8.1-bcmath php8.1-mbstring php8.1-curl php8.1-dom php8.1-mysql php8.1-zip php8.1-sqlite3 \
    libsasl2-modules postfix rsyslog -y


# Cleanup
RUN     apt-get autoremove -y && \
	apt-get clean && \
	apt-get autoclean && \
	# install composer
	curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Nginx configuration
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
	sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
	sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 128m;\n\tproxy_buffer_size 256k;\n\tproxy_buffers 4 512k;\n\tproxy_busy_buffers_size 512k/" /etc/nginx/nginx.conf && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	# PHP-FPM configuration
	sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/8.1/fpm/php.ini && \
	#sed -i -e "s/;opcache.enable\s*=\s*1/opcache.enable=0/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/;opcache.memory_consumption\s*=\s*128/opcache.memory_consumption=256/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/;opcache.max_accelerated_files\s*=\s*10000/opcache.max_accelerated_files=20000/g" /etc/php/8.1/fpm/php.ini && \
	#sed -i -e "s/;opcache.validate_timestamps\s*=\s*1/opcache.validate_timestamps=0/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/;realpath_cache_size\s*=\s*4096k/realpath_cache_size=4096K/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/;realpath_cache_ttl\s*=\s*120/realpath_cache_ttl=600/g" /etc/php/8.1/fpm/php.ini && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/8.1/fpm/php-fpm.conf && \
	sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "/pid\s*=\s*\/run/c\pid = /run/php8.1-fpm.pid" /etc/php/8.1/fpm/php-fpm.conf && \
	sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	sed -i -e "s/;clear_env = no/clear_env = no/g" /etc/php/8.1/fpm/pool.d/www.conf && \
	# remove default nginx configurations
	rm -Rf /etc/nginx/conf.d/* && \
	rm -Rf /etc/nginx/sites-available/default && \
	mkdir -p /etc/nginx/ssl/ && \
	# create workdir directory
	mkdir -p /var/www

COPY ./config/php/xdebug.ini /etc/php/8.1/mods-available/xdebug.ini
COPY ./config/nginx/nginx.conf /etc/nginx/sites-available/default.conf
# Supervisor Config
COPY ./config/supervisor/supervisord.conf /etc/supervisord.conf
# Start Supervisord
COPY ./config/cmd.sh /
# mount www directory as a workdir
COPY ./www/ /var/www

RUN rm -f /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default && \
	chmod 755 /cmd.sh && \
	chown -Rf www-data.www-data /var/www && \
	touch /var/log/cron.log && \
	touch /etc/cron.d/crontasks && \
	mkdir -p /tmp/laravel/storage/app && \
	mkdir -p /tmp/laravel/storage/framework/cache/data && mkdir -p /tmp/laravel/storage/framework/views && \
	mkdir -p /tmp/laravel/storage/logs && \
	chown -R www-data:www-data /tmp/laravel

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/bin/bash", "/cmd.sh"]
