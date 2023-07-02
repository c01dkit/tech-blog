# 环境配置

## 更新基本环境

```shell
sudo apt update
sudo apt install curl build-essential gcc make -y
```

## 安装rust

```shell
curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh
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

```shell
evel `ssh-agent`
ssh-add <私钥文件>
```

## 参考文章

* 安装rust[https://hosthum.com/p/install-rust-lang/](https://hosthum.com/p/install-rust-lang/)
* 安装ohmyzsh[https://ohmyz.sh/](https://ohmyz.sh/)
* 配置Intel PT[https://carteryagemann.com/a-practical-beginners-guide-to-intel-processor-trace.html](https://carteryagemann.com/a-practical-beginners-guide-to-intel-processor-trace.html)
* 配置ssh-agent[https://blog.csdn.net/shadow_zed/article/details/112260652](https://blog.csdn.net/shadow_zed/article/details/112260652)