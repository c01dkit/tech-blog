# 代理转发

## 多台电脑组局域网

可以使用[zerotier](https://www.zerotier.com/)，登录以后创建一个网络。然后需要组局域网的设备下载zerotier以后join上就行了。

可以参考[这里](https://byteage.com/157.html)的链接配置私有planet，既能提高安全性，又能加快连接速度。简单来说，需要用ZeroTier官方代码编译自己的planet文件并替换掉zerotier客户端使用的planet，然后用ztncui这个后台管理界面配置zerotier的许可。

## 内网穿透

需要公网服务器，可以在阿里云租一个

一种方法是frp

另一种方法是ssh正向连接配合反向连接：

首先内网服务器开个screen运行`ssh -R 127.0.0.1:1234:127.0.0.1:22 user@ip -p port`连接到云服务器上。这样的话云服务器访问127.0.0.1:1234就相当于访问内网的127.0.0.1:22。然后需要连接内网的主机也开个screen运行`ssh -L 127.0.0.1:2345:127.0.0.1:1234 user@ip -p port`，这样的话该主机访问自己127.0.0.1:2345就相当于访问云服务器的127.0.0.1:1234。然后该主机再开一个终端，`ssh user@127.0.0.1 -p 2345`即可。

方便起见也可以在.ssh/config文件里用`RemoteForward ip1:port1 ip2:port2`和`LocalForward ip1:port1 ip2:port2`来简化每次ssh连接都这么搞。

## 子网转发

希望将某端口收到的消息转发到其他主机的某一端口，可以试试socat，比如`socat TCP4-LISTEN:4320,fork TCP4:10.244.55.25:80`，可以把4320端口收到的TCP4数据包转发到子网10.244.55.25的80端口，配合zerotier可以实现内网对外开放端口。

即，`vi /etc/systemd/system/socat.service`编辑如下的socat，并`systemctl enable socat.service`启用开机启动，然后`systemctl start socat.service`。为了支持https连接，使用TCP-LISTEN/TCP。需要目标主机那边配置好ssl证书。

```shell
[Unit]
Description=port forward 4320

[Service]
User=nobody
ExecStart=/usr/bin/socat TCP-LISTEN:4320,reuseaddr,fork TCP:<目标域名>:443

[Install]
WantedBy=multi-user.target
```