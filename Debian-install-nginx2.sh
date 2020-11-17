#!/bin/bash
#更新系统软件
# apt update && apt upgrade -y
# #安装依赖环境
# apt-get install build-essential libpcre3 libpcre3-dev libssl-dev git zlib1g-dev -y
# #添加用户
# adduser --system --home /nonexistent --shell /bin/false --no-create-home --gecos "nginx user" --group --disabled-login --disabled-password nginx
# cd ~ 
# #取得模块文件及Nginx源码
# git clone git://github.com/FRiCKLE/ngx_cache_purge.git
# git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module
# git clone git://github.com/openresty/headers-more-nginx-module.git
# wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz && tar xzvf pcre-8.43.tar.gz
# wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz
# wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz && tar xzvf openssl-1.1.1d.tar.gz
# wget https://nginx.org/download/nginx-1.16.1.tar.gz && tar zxvf nginx-1.16.1.tar.gz
cd nginx-1.16.1
#编译安装
./configure --prefix=/etc/nginx2 --sbin-path=/usr/sbin/nginx2 --modules-path=/usr/lib/nginx2/modules --conf-path=/etc/nginx2/nginx.conf --error-log-path=/var/log/nginx2/error.log --http-log-path=/var/log/nginx2/access.log --pid-path=/var/run/nginx2.pid --lock-path=/var/run/nginx2.lock --http-client-body-temp-path=/var/cache/nginx2/client_temp --http-proxy-temp-path=/var/cache/nginx2/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx2/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx2/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx2/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-pcre=../pcre-8.43 --with-pcre-jit --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1d --with-openssl-opt=no-nextprotoneg --with-debug --add-module=../ngx_cache_purge --add-module=../ngx_http_substitutions_filter_module --add-module=../headers-more-nginx-module
sleep 1
make && make install
cd ~ 
#创建软连接及目录
ln -s /usr/lib/nginx2/modules /etc/nginx2/modules
mkdir /var/cache/nginx2 -p
mkdir /etc/nginx2/vhost -p
#添加虚拟主机支持
cp /etc/nginx2/nginx.conf /etc/nginx2/nginx.conf.bak
wget -q -O nginx.conf https://raw.githubusercontent.com/zunsking/Debian-Install-Nginx/master/nginx.conf
\cp nginx.conf /etc/nginx2/
#注册系统服务
cat >/lib/systemd/system/nginx2.service << EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
[Service]
Type=forking
PIDFile=/var/run/nginx2.pid
ExecStartPre=/usr/sbin/nginx2 -t -c /etc/nginx2/nginx.conf
ExecStart=/usr/sbin/nginx2 -c /etc/nginx2/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
[Install]
WantedBy=multi-user.target
EOF
#开机启动及状态检查
systemctl daemon-reload
systemctl enable nginx2.service
systemctl start nginx2.service
systemctl status nginx2.service
