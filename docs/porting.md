# 折腾网站

## 端口复用方法

由于服务器安全设定，只对外开放一个22端口提供ssh连接。那么在此基础上如何提供http、https等多种服务？搜索了下可以根据流量特征用sslh简单转发一下数据包到不同的内部端口。

### sslh：根据流量特征转发数据包

在root下apt install sslh后修改配置文件`/etc/default/sslh`：


```shell
# Default options for sslh initscript
# sourced by /etc/init.d/sslh

# binary to use: forked (sslh) or single-thread (sslh-select) version
# systemd users: don't forget to modify /lib/systemd/system/sslh.service
DAEMON=/usr/sbin/sslh
Run=yes
DAEMON_OPTS="--user sslh --listen 0.0.0.0:4684 --ssh 127.0.0.1:5752 --tls 127.0.0.1:443 --http 127.0.0.1:1284 --anyprot 127.0.0.1:2008 -F /etc/sslh/sslh.cfg --pidfile /var/run/sslh/sslh.pid"
```

这里也可以`cat /lib/systemd/system/sslh.service`看一下service文件，其中有一行`ExecStart=/usr/sbin/sslh --foreground $DAEMON_OPTS`，可以看到在启动sslh时参数是DAEMON_OPTS。所以重点就在于配置好DAEMON_OPTS。

解释一下几个参数的意思：

* `--listen 0.0.0.0:4684` 表示sslh运行在4684端口，将这个端口收到的数据包按规则转发到其他端口上
* `--ssh 127.0.0.1:5752` 表示将收到的ssh数据包转发到本地5752端口
* `--tls 127.0.0.1:443` 表示将收到的tls数据包转发到本地443端口
* `--http 127.0.0.1:1284` 表示将收到的http请求转发到本地1284端口
* `--anyprot 127.0.0.1:2008` 表示将匹配都不符合的包发送到本地2008端口
* `-F /etc/sslh/sslh.cfg` 表示使用sslh.cfg这个文件中的设定进行更丰富的配置

然后`systemctl enable sslh`、`systemctl start sslh`启动sslh，将本地4684端口收到的流量根据ssh、ssl、http的特征分别进行端口转发。

比较有意思的是可以用`--anyprot`来设置默认的转发策略，配合`nc -lk`可以看自定义的数据包格式，再通过`-F`（或`--config`）指定config文件（比如/etc/sslh/sslh.cfg），实现利用正则表达式对数据包进行自定义转发。

注意，如果使用config文件，那么文件的内容不要和命令行已有的内容重复。比如命令行已经指定了监听127.0.0.1端口的4684，那config文件里就不要再加上listen:(xxx)了。

config文件指定匹配规则的例子如下所示（片段）

```c
protocols:
(
    { name: "http"; host: "127.0.0.1"; port: "808"; },
    { name: "tls"; host: "127.0.0.1"; port: "443"; sni_hostnames: [ "remote.c01dkit.com" ]; tfo_ok: true },
    { name: "tls"; host: "127.0.0.1"; port: "7000"; sni_hostnames: [ "project-frp" ]; tfo_ok: true },
    { name: "regex"; host: "127.0.0.1"; port: "60000"; regex_patterns: [ "^SSH-2.0-Go\x0d$", "^SSH-2.0-OpenSSH\x0d$" ]; },
);
```

### ssh：提供远程连接

由于原本对外开放的22端口只用于接收ssh请求，如果想要提供更多服务，需要先把22端口的接收的数据都转发给sslh，让它来进行分类。那么ssh请求应该就不能再还给22端口了（不然可能又被转发给sslh？不确定），可以考虑再开一个端口监听ssh请求。这里ssh的设定开了本地22和5752端口，配置时修改`/etc/ssh/sshd_config`文件，加一行Port 5752即可。同时记得使用公钥认证登录，禁用密码登录。

```shell
Port 22
Port 5752
PubkeyAuthentication yes
PasswordAuthentication no
```

### nginx：提供http/https服务

在nginx官网下载源码并按说明编译。nginx（1.22版本）的配置如下：

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

这里配置了nginx监听本地1284端口来处理http访问，将https请求转发到443端口，也设置了ssl的证书。证书的配置方法可以见后文的`https证书`章节。

关于nginx，可以nginx -V查看编译选项，然后自己从源码编译下。常见的-V输出有：

```
nginx version: nginx/1.22.1
built by gcc 11.3.0 (Ubuntu 11.3.0-1ubuntu1~22.04) 
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --user=c01dkit --group=c01dkit --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
```

这里指定user为c01dkit，然后网站也都放在c01dkit的家目录里面，以防网站页面因为权限问题打不开（好像默认是www-data），可能是蟹脚改法○( ＾皿＾)っ

### iptables：转发外部访问到sslh

最后接着设置防火墙将所有外部流量从开放的唯一端口转发到4684端口即可。

```shell
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 4684
```

这里假定外部端口开放的端口映射到本地22端口。这里22端口也是有ssh服务在监听。

有时担心sslh服务挂掉导致4684没有ssh服务、ssh连不上，设置了定时任务来关掉、打开防火墙（此时只能ssh连接，提供运维窗口期），比如每周三4点到6点只提供22端口的ssh服务：

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

由于这样设置iptables会在服务器重启后失效，所以服务器意外重启的话只不过是恢复到最基础的22端口ssh而已。



## https证书

关于https证书，可以按[这里](https://certbot.eff.org/)的方法，先`snap install --classic certbot`安装certbot，（不知道为啥当时设置了一下certbot路径`sudo ln -s /snap/bin/certbot /usr/bin/certbot`）。如果80端口已经对外开放，可以简单地`certbot --nginx`自动帮忙认证（即certbot创建认证文件然后在公网访问）。如果80端口不对外开放，可以自选dns认证：`certbot certonly --manual --preferred-challenges=dns`然后在域名管理那边添加一下记录即可，比如创建一个_acme-challenge.remote的TXT记录。然后在nginx的conf那里设置好证书路径，访问就有https认证了！对于http访问，可以用301跳转。

一次认证是90天有效期，到期之前会发邮件，更新证书时需要运行`certbot renew  --manual-auth-hook=xxx.sh` 其中sh脚本是自己编写的一个自动化完成DNS记录更新。为了懒省事，可以这么写：

```shell
echo ${CERTBOT_VALIDATION} >> xxx.txt
echo ${CERTBOT_DOMAIN} >> xxx.txt
sleep 120
exit 0
```

然后在两分钟之内，把xxx.txt里CERTBOT_VALIDATION对应的哈希值手动更新在DNS记录里即可。

此外，新找到一个可以方便地在web端配置新证书的网站：[https://xiangyuecn.github.io/ACME-HTML-Web-Browser-Client/ACME-HTML-Web-Browser-Client.html](https://xiangyuecn.github.io/ACME-HTML-Web-Browser-Client/ACME-HTML-Web-Browser-Client.html)