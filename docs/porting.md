# 端口复用方法

由于服务器安全设定，只对外开放一个端口，如何提供ssh连接、https服务？搜索了下可以根据流量特征用sslh简单转发一下数据包到不同的内部端口。在root下apt install sslh后修改配置：


```shell
# Default options for sslh initscript
# sourced by /etc/init.d/sslh

# binary to use: forked (sslh) or single-thread (sslh-select) version
# systemd users: don't forget to modify /lib/systemd/system/sslh.service
DAEMON=/usr/sbin/sslh
Run=yes
DAEMON_OPTS="--user sslh --listen 0.0.0.0:4684 --ssh 127.0.0.1:5752 --ssl 127.0.0.1:443 --http 127.0.0.1:1284 --pidfile /var/run/sslh/sslh.pid"
```

ssh的设定开了本地22和5752端口，配置时修改/etc/ssh/sshd_config文件，加一行Port 5752即可。同时记得使用公钥认证登录，禁用密码登录。nginx（1.22版本）的配置如下

```
user  c01dkit;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server_tokens off;
    server {
        listen       1284;
		listen       127.0.0.1:1284;
        charset utf-8;
        server_name  xxxx.c01dkit.com;
		if ($scheme = http ) {
			return 301 https://$host:xxxx$request_uri;	
		}
        error_page  404              /404.html;
    }

    server {
		listen       127.0.0.1:443 ssl ;
        listen       443 ssl ;
		listen       [::]:443 ssl ;
        server_name  xxxx.c01dkit.com;
        charset utf-8;
        ssl_certificate      xxxx/fullchain.pem;
        ssl_certificate_key  xxxx/privkey.pem;

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location / {
            root   xxxxx;
            index  index.html index.htm;
            error_page  404              /404.html;

        }
        location ~ \.php$ {
            fastcgi_pass   unix:/run/php/php8.1-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  xxxx/www$fastcgi_script_name;
            include        fastcgi_params;
            error_page  404              /404.html;
        }
    }

}

```


然后systemctl enable sslh、systemctl start sslh启动sslh。这里将本地4684端口收到的流量根据ssh、ssl、http的特征分别进行端口转发。此时接着设置防火墙将所有外部流量转发到4684端口即可。这里假定ssh服务也开在了5752端口，nginx配置https监听443端口、http监听1284端口。

```shell
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 4684
```

这里假定外部端口开放的端口映射到本地22端口。这里22端口也是有ssh服务在监听。有时担心sslh服务挂掉导致4684没有ssh服务、ssh连不上，设置了定时任务来关掉、打开防火墙（此时只能ssh连接，提供运维窗口期），比如每周三4点到6点只提供22端口的ssh服务：

```shell
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
0 4 * * 3 iptables -t nat -D PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 4684
0 6 * * 3 iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 4684
```

由于这样设置iptables重启后会失效，所以服务器意外重启的话只不过是恢复到最基础的22端口ssh而已。

关于nginx，可以nginx -V查看编译选项，然后自己从源码编译下。常见的-V输出有：
```
nginx version: nginx/1.22.1
built by gcc 11.3.0 (Ubuntu 11.3.0-1ubuntu1~22.04) 
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --user=c01dkit --group=c01dkit --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
```

这里指定user为c01dkit，然后网站也都放在c01dkit的家目录里面，以防网站页面因为权限问题打不开（好像默认是www-data），可能是蟹脚改法○( ＾皿＾)っ

关于https证书，可以按[这里](https://certbot.eff.org/)的方法，先`snap install --classic certbot`安装certbot，（不知道为啥当时设置了一下certbot路径`sudo ln -s /snap/bin/certbot /usr/bin/certbot`）。如果80端口已经对外开放，可以简单地`certbot --nginx`自动帮忙认证（即certbot创建认证文件然后在公网访问）。如果80端口不对外开放，可以自选dns认证：`certbot certonly --manual --preferred-challenges=dns`然后在域名管理那边添加一下记录即可。然后在nginx的conf那里设置好证书，访问就有https认证了！对于http访问，可以用301跳转。