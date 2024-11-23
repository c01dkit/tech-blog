# 环境配置

经常遇到新系统快速配置的环境（wsl、新服务器），特此总结一下

## Ubuntu更新基本环境

```shell
sudo apt update
sudo apt install curl build-essential gcc make -y
```
## 安装docker

按照[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)的说明安装即可

也可以按`curl -fsSL https://get.docker.com -o get-docker.sh`、`sudo sh get-docker.sh`来安装。

## rust安装与更新

```shell
curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh
```

```shell
rustup update
```

国内使用时crates.io可能登不上，试试修改安装目录下的config文件(比如$HOME/.cargo/config)

```text
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

# 替换成你偏好的镜像源
#replace-with = 'sjtu'
#replace-with = 'ustc'
#replace-with = 'tuna'
#replace-with = 'rustcc'

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# 中国科学技术大学
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

# rustcc社区
[source.rustcc]
registry = "git://crates.rustcc.cn/crates.io-index"

[source.rustcchttp]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
```

## 设置golang代理

``` go 
go env -w  GOPROXY=https://goproxy.cn
```

## 安装ohmyzsh

```shell
sudo apt install zsh
```

curl和wget二选一

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

```shell
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

个人觉得jonathan的主题比较好看，可以配置下~/.zshrc的ZSH_THEME。

## git设置全局代理

需要根据本地实际的情况修改目标ip和端口

```shell
git config --global http.https://github.com.proxy http://xxx.xxx.xxx.xxx:xxx
```

## perf 安装(ubuntu)

```shell
sudo apt-get install linux-tools-`uname -r`
```

## 选择ssh密钥

会在当前terminal创建一个agent，后续默认使用这个agent进行ssh操作。对于有密码的私钥或者自定义命名私钥来说比较好用。

```shell
evel `ssh-agent`
ssh-add <私钥文件>
```

## Windows下安装make

使用chocolatey包管理器。按[https://chocolatey.org/install#individual](https://chocolatey.org/install#individual)的说明即可，最后`choco install make`

## 更改WSL2镜像位置

* 【查询】 `wsl -l --all -v`
* 【关闭系统】 `wsl --shutdown <镜像名>`
* 【导出系统备份】 `wsl --export <镜像名> <备份保存位置.tar>`
* 【取消注册】 `wsl --unregister <镜像名>`
* 【导入系统备份】 `wsl --import <镜像名> <导出路径> <备份保存位置.tar> --version 2`

## nodejs配置

下载[https://nodejs.org/en/download/](https://nodejs.org/en/download/)

npm设置国内源： `npm config set registry="http://r.cnpmjs.org"`


## 快速部署发布vue站点

在要保存项目目录的目录里，运行`npm create vue@latest`，随后会引导创建项目名等。进入项目后，先`npm install`，然后可以使用`npm run dev`和`npm run build`来生成网站。

使用`docker pull nginx`直接拉取新的nginx镜像，然后`docker run -itd --name=<容器名字> -p 4000:80 -v /vue项目路径/dist:/usr/share/nginx/html nginx`来直接提供网站服务。注意这里是将主机4000端口映射到80端口，同时将`npm run build`生成的网站挂载到nginx的默认站点目录中（nginx版本1.25）。

可以在外部访问一下，如果看到的网站是nginx默认页面，可以docker exec到nginx容器里检查下`/etc/nginx/conf.d/default.conf`（或相似的其他conf路径，根据nginx版本有所区别），看看root到底是用哪个目录作为站点的。

## 安装Chrome浏览器

有时候需要用ssh的X11 Forward功能，连接服务器上的浏览器。

```shell
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >>   /etc/apt/sources.list
sudo apt-get update 
sudo apt-get install google-chrome-stable

```

安装好后，用非root用户，ssh -X连接服务器，再运行chrome-google即可打开浏览器。

## 安装简中字体

```shell
apt install ttf-wqy-zenhei
apt install fonts-wqy-microhei # 安装一个就行
fc-cache # 刷新缓存
fc-list # 检查列表
```

## 参考文章

* 安装rust[https://hosthum.com/p/install-rust-lang/](https://hosthum.com/p/install-rust-lang/)
* 安装ohmyzsh[https://ohmyz.sh/](https://ohmyz.sh/)
* 配置Intel PT[https://carteryagemann.com/a-practical-beginners-guide-to-intel-processor-trace.html](https://carteryagemann.com/a-practical-beginners-guide-to-intel-processor-trace.html)
* 配置ssh-agent[https://blog.csdn.net/shadow_zed/article/details/112260652](https://blog.csdn.net/shadow_zed/article/details/112260652)