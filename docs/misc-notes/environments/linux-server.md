# Ubuntu服务器运维

## 根据pid查询细节

```shell
sudo ls -lah /proc/<pid>
```
然后根据其中的cwd找到运行目录，exe找到运行程序

## 在终端向程序输入字节

```shell
# 输入raw bytes
echo -e '\x31\x32' | program

# 不带echo自动加的换行
echo -en '\x31\x32' | program

# 输入raw binary
echo -e '\x31\x32' | xxd -r -p | program 
```

## 修改服务器时间

使用`date`查看时区默认UTC，比北京时间慢8小时。可以使用`timedatectl set-timezone Asia/Shanghai`来调整时区。调整24小时制时，设置`/etc/default/locale`的LC_TIME为"zh_CN.UTF-8"，或者为当前用户`export LC_TIME="zh_CN.UTF-8"`。

## 查询服务器显卡

查询物理槽显卡连接

```shell
lspci | grep VGA
```

查询活跃情况（需要安装显卡驱动，可以[直接安装CUDA runfile](https://developer.nvidia.com/cuda-toolkit-archive)，自带驱动）

```shell
nvidia-smi
```

## 统计服务器进程占用

```shell
htop # 观察内存、各进程、CPU占用
sudo ls -lah /proc/<pid>/cwd # 观察运行的命令，判断谁的程序
```

## 统计磁盘用量

```shell
ncdu # 统计当前目录下各个文件夹占用，可以进入、删除文件夹或目录
```

## sudo权限

使用`visudo`然后编辑文本即可，比如在文件最后添加`<username> ALL=(ALL) NOPASSWD: ALL`

## 修改DNS

有时候连不上网是因为DNS的问题，修改/etc/resolve.conf即可。不过这个软连接修改完了以后可能会被系统改掉，可以试试删掉以后直接创建个/etc/resolve.conf文件，再`chattr +i /etc/resovle.conf`防止修改。

## 系统服务

`systemctl status xxx`检查某些服务运行状态，可以`ls -lah /etc/systemd/system`、`ls -lah /lib/systemd/system`查询有哪些服务。警惕奇怪的数字service，可能是病毒。

添加系统服务（即创建一个systemd的守护后端）时，创建`/etc/systemd/system/xxx.service`文件，然后编辑内容，比如下面的mysocat.service：

```shell
[Unit]
Description=port forward 4320
# 启动顺序（多个服务中间用空格隔开）
After=network.target #[当前服务在指定服务之后启动]
#Before=[当前服务在指定服务之前启动]

# 依赖关系
#Wants=[弱依赖关系服务，指定服务发生异常不影响当前服务]
#Requires=[强依赖关系服务，指定服务发生异常，当前服务必须退出]

[Service]
User=nobody
WorkingDirectory=[程序工作的绝对路径]
ExecStart=/usr/bin/socat TCP4-LISTEN:4320,fork TCP4:10.244.55.25:80
# 如果需要运行有venv的python程序，比如source .venv/bin/activate之后再用python，那在ExecStart这里直接写xxx/.venv/bin/python即可，不需要运行source
# ExecReload=[重启服务时执行的命令]
# ExecStop=[停止服务时执行的命令]
# ExecStartPre=[启动服务之前执行的命令]
# ExecStartPost=[启动服务之后执行的命令]
# ExecStopPost=[停止服务之后执行的命令]

# 启动类型
#Type=simple
# simple（默认值）：ExecStart字段启动的进程为主进程
# forking：ExecStart字段将以fork()方式启动，此时父进程将会退出，子进程将成为主进程
# oneshot：类似于simple，但只执行一次，Systemd 会等它执行完，才启动其他服务
# dbus：类似于simple，但会等待 D-Bus 信号后启动
# notify：类似于simple，启动结束后会发出通知信号，然后 Systemd 再启动其他服务
# idle：类似于simple，但是要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合

# 如何停止服务
# control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉
# process：只杀主进程
# mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
# none：没有进程会被杀掉，只是执行服务的 stop 命令。
#KillMode=[如何停止服务]

# 重启方式 [服务退出后，Systemd 的重启方式]
Restart=always
# no（默认值）：退出后不会重启
# on-success：只有正常退出时（退出状态码为0），才会重启
# on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
# on-abnormal：只有被信号终止和超时，才会重启
# on-abort：只有在收到没有捕捉到的信号终止时，才会重启
# on-watchdog：超时退出，才会重启
# always：不管是什么退出原因，总是重启

RestartSec=3 #[表示 Systemd 重启服务之前，需要等待的秒数]

Environment="TEST=1" #[设置环境变量]

[Install]
WantedBy=multi-user.target
# 执行 sytemctl enable **.service命令时，**.service的一个符号链接，就会放在/etc/systemd/system/multi-user.target.wants子目录中
# 执行systemctl get-default命令，获取默认启动Target
# multi-user.target组中的服务都将开机启动
# 常用Target，1. multi-user.target-多用户命令行；2. graphical.target-图形界面模式
```

随后运行

```shell
sudo systemctl daemon-reload
sudo systemctl start mysocat
sudo systemctl enable mysocat
```


* 启动`systemctl start **`
* 关闭`systemctl stop **`
* 重启`systemctl restart **`
* 查看运行状态`systemctl status **`
    * Loaded行：配置文件的位置，是否设为开机启动；
    * Active行：表示正在运行；
    * Main行：主进程PID；
    * Status行：由应用本身提供的软件当前状态；
    * CGroup行：应用的所有子进程
    * 日志块：应用的日志
* 设置开机自启`systemctl enable **` enable命令相当于在目录里添加了一个符号链接。开机时，Systemd会执行/etc/systemd/system/目录里面的配置文件
* 结束服务进程`systemctl kill **`
* 查看配置文件`systemctl cat **`
* 查看multi-user.target 包含的所有服务`systemctl list-dependencies multi-user.target`
* 切换到另一个 target `systemctl isolate graphical.target`
* 重新加载配置文件`systemctl daemon-reload`

## 定时服务

定时程序执行失败的原因是多样的，可能是因为定时服务没启动，需要`systemctl restart cron.service`，或者是cron服务坏掉了，先`apt install cron --reinstall`强制重新安装下，再重启服务，或者是安装了别的依赖库但是没有重启cron导致运行失败，试试`/etc/init.d/cron restart`。


## 打开文件数

https://www.baeldung.com/linux/list-open-file-descriptors

Linux默认最多同时打开1024个文件，可以通过`ulimit -n`查看。fuzzing等要注意关闭文件描述符，否则可能导致服务器故障（比如ssh连不上）。`/proc/<pid>/fd`里列出了pid锁打开的文件。

## ssh安全加固

首先要禁用密码登录，采取仅公钥认证方法，且使用ed25519算法。此外，使用fail2ban来封禁那些尝试爆破ssh的ip。

使用`last`查看近期成功登录的用户，使用`lastb`查看近期登录失败的用户。

```bash
sudo fail2ban-client status # 查询规则列表
sudo fail2ban-client status sshd # 查询sshd服务封禁情况
sudo fail2ban-client set <jail_name> banip <ip_address> # 将某ip添加到某禁止列表里
sudo fail2ban-client set <jail_name> unbanip <ip_address> # 解封某列表的ip

```

## 图形化界面

一般来说sshd默认打开X11forward了，ssh命令加上`-X`参数，就可以使用图形化应用，比如xclock。如果在config里配置，可以添加`ForwardX11 yes`和`ForwardX11Trusted yes`的配置选项。

能用vnc还是用vnc，比ssh的图形化快多了。参考 https://gist.github.com/ppoffice/53347bc47edb1c5903c70a79f0a5e290

```shell
sudo apt update
sudo apt install tigervnc-standalone-server -y
sudo apt install ubuntu-desktop # 如果安装的是ubuntu-server，可以安装这个gnome，也支持图形化。
vncpasswd # 设置密码
touch ~/.vnc/xstartup
touch ~/.Xresources
#sudo dpkg-reconfigure gdm3
#cat /etc/X11/default-display-manager
```

修改`~/.vnc/xstartup`文件内容如下：

```shell
#!/bin/sh

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
export DESKTOP_SESSION=/usr/share/xsessions/ubuntu.desktop
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop
dbus-launch --exit-with-session /usr/bin/gnome-session --systemd --session=ubuntu
```

然后服务器vncserver -localhost :1可以在5901端口启动一个仅允许本地连接的vnc服务，主机用ssh -L 5901:localhost:5901 user@ip 连接后，用vnc软件继续连接即可。当然也可以直接vncserver启动一个外部也可以访问的vnc服务。

在Ubuntu 24.04 Desktop端使用上述配置文件似乎有点问题，可以先装上xfce `sudo apt install xfce4 xfce4-goodies -y`然使用以下配置：

```shell
#!/bin/sh

# 1. 修复环境变量，防止与本地桌面冲突
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# 2. 加载 X 资源（如果有）
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

# 3. 启动剪贴板支持工具 (放在后台运行)
vncconfig -iconic &

# 4. 启动 XFCE4 桌面
# 注意：这里直接使用 startxfce4，不要加 & 符号在最后
# 这样 VNC 会确保持续运行直到你注销桌面
exec startxfce4
```

## 低资源云服务器运行高负载命令导致卡死

一些廉价服务器，比如阿里的年费99元的2核2G内存的云服务器，在运行IO密集型操作比如npm install时可能会直接导致ssh断连。此时可以限制一下对cpu和内存的使用率：

```shell
systemd-run --scope -p CPUQuota=50% -p MemoryMax=1G -p IOWeight=10 nice -n 19 npm install
```

也记得用swap缓解一下内存不够的问题，比如分配8G空间给swapfile，并设置在内存压力下提前使用swap：

```shell
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=60 # 越接近100越积极使用swap
echo 'vm.swappiness=60' >> /etc/sysctl.conf
sysctl -p
```

## 参考资料

1. [systemd相关资料](https://zhuanlan.zhihu.com/p/415469149)