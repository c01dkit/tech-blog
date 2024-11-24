# LLVM 学习

## 环境配置

### 源码编译

首先在https://github.com/llvm/llvm-project/releases/ 下载心仪的`llvm-project-xx.x.x.src.tar.xz`，然后`tar -xf llvm*`解压缩后按如下进行编译：

```shell
cd llvm-project-*
mkdir build && cd build
cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=On -DLLVM_TARGETS_TO_BUILD=host ../llvm
cmake --build . -j8 # make -j8  根据实际情况选择多线程编译
```

然后把生成的build/bin目录加到PATH里，把build目录设为LLVM_DIR全局变量。

```shell
export PATH=<installation/dir/of/llvm/18/bin>:/$PATH
export LLVM_DIR=<installation/dir/of/llvm/18>
```

`<installation/dir/of/llvm/18>`即之前在llvm-project文件夹里创建的build目录。

### 多版本llvm切换

参考[CSDN博客](https://blog.csdn.net/weixin_45100742/article/details/139897786)

```shell
# 首先，添加所有可用的 llvm-config 版本到 update-alternatives。最后的20、10表示权重
sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-15 20
sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-18 10
# 选择默认版本
sudo update-alternatives --config llvm-config

# 添加所有可用的 clang 版本到 update-alternatives
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 20
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 10
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang-15 20
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang-18 10
# 选择默认版本
sudo update-alternatives --config clang
sudo update-alternatives --config clang++

# 查看llvm版本
llvm-config --version
# 查看clang版本
clang --version
```


## 快速上手

接下来推荐这个github项目https://github.com/banach-space/llvm-tutor，按HelloWorld: Your First Pass章节继续操作即可。

```shell
# 在llvm-tutor/HelloWorld目录下，首先生成Pass的.so文件

mkdir build
cd build
cmake -DLT_LLVM_INSTALL_DIR=$LLVM_DIR .. # 用于定位LLVMConfig.cmake文件，从而帮助设置库文件路径
make

# 然后编译需要插桩的文件
clang -O1 -S -emit-llvm <source/dir/llvm/tutor>/inputs/input_for_hello.c -o input_for_hello.ll

# 最后执行文件
opt -load-pass-plugin ./libHelloWorld.so -passes=hello-world -disable-output input_for_hello.ll
```

## 补充解释

opt是一个命令行工具，用于在LLVM IR层面上进行代码优化。 它可以应用各种各样的优化策略，如死代码消除、常量折叠等，以提高生成代码的效率。

## 中间文件

LLVM Pass工作在LLVM IR文件的基础之上。IR包括ll（文本格式，便于人工阅读）和bc（字节码）两种形式。源码、IR、汇编代码的互相转化方法如下所示：

```
.c -> .ll: clang -emit-llvm -S a.c -o a.ll
.c -> .bc: clang -emit-llvm -c a.c -o a.bc
.ll -> .bc: llvm-as a.ll -o a.bc
.bc -> .ll: llvm-dis a.bc -o a.ll
.bc -> .s: llc a.bc -o a.s
```