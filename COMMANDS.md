docker build -t realmdigital/nginx-php8.x:8.0 .
docker build -t realmdigital/nginx-php8.x:8.0.[THE_PATCH_VERSION_THAT_YOU_CAN_FIND_IN_THE_PREVIOUS_BUILD_STEP] .
docker build -t realmdigital/nginx-php8.x:latest .
docker push realmdigital/nginx-php8.x:8.0
docker push realmdigital/nginx-php8.x:8.0.[THE_PATCH_VERSION]
docker push realmdigital/nginx-php8.x:latest

# comment out from 
# sed -i -e "s/;opcache.memory_consumption\s*=\s*128/opcache.memory_consumption=256/g" /etc/php/8.0/fpm/php.ini && \
# upto and including
# sed -i -e "s/;realpath_cache_ttl\s*=\s*120/realpath_cache_ttl=600/g" /etc/php/8.0/fpm/php.ini && \
docker build -t realmdigital/nginx-php8.x:8.0-dev .
docker build -t realmdigital/nginx-php8.x:8.0.[THE_PATCH_VERSION]-dev .
docker push realmdigital/nginx-php8.x:8.0.[THE_PATCH_VERSION]-dev
docker push realmdigital/nginx-php8.x:8.0-dev

