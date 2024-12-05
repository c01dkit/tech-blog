# OpenSSH阅读笔记

## 准备工作

(以下均在wsl的root用户) ubuntu系统，先预装下环境：

```shell
apt install build-essential autoconf zlib1g-dev libssl-dev
```

下载源码，直接从[Github链接](https://github.com/openssh/openssh-portable)下载zip到本地解压，也可以用git clone：

```shell
git clone --depth 1 https://github.com/openssh/openssh-portable.git
```

为了防止之后make install出的文件覆盖系统自己的ssh，这里指定configure将之后编译出的文件放到项目的/output文件夹下。按readme的Building from git的方法，进入openssh所在目录后，运行：

```shell
autoreconf
./configure --prefix=`pwd`/output
make
```

此时相关可执行文件已经编译完毕。为了进一步清晰显示，可以运行`make install`，则在当前目录的output文件夹下会生成对应的结构。
