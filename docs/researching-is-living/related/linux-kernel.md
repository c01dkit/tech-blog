# linux内核编译

## 编译

下载源码，可以从清华源pull一个：`git clone https://mirrors.tuna.tsinghua.edu.cn/git/linux.git`。随后编译源码，参考[CSDN教程](https://blog.csdn.net/weixin_43850253/article/details/109054516#t5)。核心逻辑是下载好必要的依赖包（比如`apt install build-essential flex bison libssl-dev libelf-dev`）之后，在根目录运行`make menuconfig`，然后Exit保存文件，最后直接多线程编译`make -j8`。

随后是漫长的编译过程。以Linux 6.12-rc6为例可能出现的报错：

证书问题：

```
make[3]: *** No rule to make target 'debian/canonical-certs.pem', needed by 'certs/x509_certificate_list'.  Stop.
make[2]: *** [scripts/Makefile.build:478: certs] Error 2
make[2]: *** Waiting for unfinished jobs....
```
参考[StackOverflow](https://stackoverflow.com/questions/67670169/compiling-kernel-gives-error-no-rule-to-make-target-debian-certs-debian-uefi-ce)上的解答，可以修改conf文件，也可以简单地运行

```shell
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
```
重新make后一路回车。

清理编译结果，可以使用