# linux服务器运维

## 根据pid查询细节

```shell
sudo ls -lah /proc/<pid>
```
然后根据其中的cwd找到运行目录，exe找到运行程序

## 在linux终端向程序输入字节

```shell
# 输入raw bytes
echo -e '\x31\x32' | program

# 输入raw binary
echo -e '\x31\x32' | xxd -r -p | program 
```

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

## 修改DNS

有时候连不上网是因为DNS的问题，修改/etc/resolve.conf即可。不过这个软连接修改完了以后可能会被系统改掉，可以试试删掉以后直接创建个/etc/resolve.conf文件，再`chattr +i /etc/resovle.conf`防止修改。


