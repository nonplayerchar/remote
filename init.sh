#! /bin/bash


domain="wpize.com";
email="avavance443@gmail.com";



######################### RESOURCE CALCULATION ###########################
cpu=$(lscpu -p=CPU | grep -v '^#' | wc -l); #No. of Logical cores
workerprocesses=$cpu;
let workerrlimitnofile=$cpu*25600;
##########################################################################




################### Package Installation #################
apt update
apt install certbot -y
apt install zip unzip -y
apt install libpcre3 zlib1g libxml2 libpcre3-dev zlib1g-dev libssl-dev libgd-dev libxml2-dev libxslt-dev libgeoip-dev -y
############################################################



################################## Nginx ###################################
wget http://nginx.org/download/nginx-1.21.6.tar.gz -O nginx.tar.gz && tar -xzf nginx.tar.gz && rm nginx.tar.gz
git clone https://github.com/google/ngx_brotli.git

cd ngx_brotli && git submodule update --init && cd /root/nginx-1.21.6

./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --with-debug --with-compat --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-mail=dynamic --with-mail_ssl_module --add-module=../ngx_brotli

make && make install

wget https://raw.githubusercontent.com/nonplayerchar/metahost/main/nginx-systemd.txt -O /etc/systemd/system/nginx.service

fuser -k 80/tcp
fuser -k 443/tcp

cd
rm -r nginx-1.21.6 && rm -r ngx_brotli

#...
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

rm -r /etc/nginx/sites-enabled
rm -r /etc/nginx/sites-available
rm -r /etc/nginx/snippets
rm -r /etc/nginx/conf.d
rm /etc/nginx/fastcgi.conf
rm /etc/nginx/fastcgi_params
rm /etc/nginx/proxy_params
rm /etc/nginx/scgi_params
rm /etc/nginx/uwsgi_params

rm /etc/nginx/fastcgi.conf.default
rm /etc/nginx/fastcgi_params.default
rm /etc/nginx/scgi_params.default
rm /etc/nginx/uwsgi_params.default

mkdir /etc/nginx/confs
mkdir /etc/nginx/confs/explicit
mkdir /etc/nginx/fastcgi

wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/nginx.conf' -O /etc/nginx/nginx.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/80.conf' -O /etc/nginx/confs/80.conf

sed -i "s/domain/$domain/g" /etc/nginx/confs/80.conf;

sed -i "s/workerprocesses/$workerprocesses/g" /etc/nginx/nginx.conf;
sed -i "s/workerrlimitnofile/$workerrlimitnofile/g" /etc/nginx/nginx.conf;

systemctl restart nginx
####################################################################################


################### Making Dirs ###################
mkdir -p /var/www
mkdir /var/www/main

wget '' -O /var/www/main/index.html

chown -R www-data:www-data /var/www/* #important secuity settings
chmod 0700 -R /var/www/* #important secuity settings
###################################################






################### TLS CONFIG ####################
cd /etc/ssl && openssl dhparam -out dhparam.pem 2048 && cd
mkdir /etc/ssl/trusted
wget 'https://letsencrypt.org/certs/isrgrootx1.pem' -O /etc/ssl/trusted/chain.pem
###################################################


############## SSL GENERATION ###############
certbot certonly --agree-tos --non-interactive --email $email -d $domain --webroot --webroot-path /var/www/main

#...
chown -R www-data:www-data /etc/letsencrypt/live/ #init : one time only | after first cert. generation (full directory permission for dynamic hostnames)
chown -R www-data:www-data /etc/letsencrypt/archive/ #init : one time only | after first cert. generation (full directory permission for dynamic hostnames)
#...
chown -R www-data:www-data /etc/letsencrypt/live/$domain
chown -R www-data:www-data /etc/letsencrypt/archive/$domain

############ SSL CONFS ############
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/main.conf' -O /etc/nginx/confs/main.conf
sed -i "s/domain/$domain/g" /etc/nginx/confs/main.conf;
###################################
##############################################


systemctl enable nginx
systemctl restart nginx



################## Upgrade ##################
#apt update
apt upgrade -y
apt-get dist-upgrade -y
#needrestart
apt clean -y
apt autoclean -y
apt autoremove -y
#############################################

















