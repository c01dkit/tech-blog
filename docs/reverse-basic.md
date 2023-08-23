# 逆向基础

逆向函数时，要提前预测下函数实现机制，以节省时间。要明白哪些部分属于程序特有的实现，哪些部分属于第三方的库，不要随便进到第三方库或者底层API里面分析。

## 调用约定

cdecl（C默认）由caller负责清理栈上传入参数。

stdcall由callee负责清理栈上传入参数（Win32API），被调函数返回时使用`RETN X`来退出，相当于RETN、POP X。比如退两个参数，就RETN 8。

fastcall为了提高速度，分别使用ECX、EDX传递前两个参数，更多参数还是使用内存。
传参时都是从右向左以此压入栈中。

## 一些常见汇编操作符

`call` 包括保存返回地址、IP跳转

`retn` 即`pop EIP`

`test` 相当于AND，但是不改变普通寄存器的值，只修改EFLAGS寄存器

## NOP指令的用途

NOP指令通常用于控制时序的目的，强制内存对齐，防止流水线灾难，占据分支指令延迟，或是作为占位符以供程序的改善（或替代被移除的指令）。

## 函数执行栈帧推断

函数内部一般先会执行以下两条指令：

```asm
push ebp
mov ebp,esp
```

可以观察ebp和esp的修改情况推断函数栈帧

## 名称修饰

名称修饰（name mangling，name decoration），用来解决标志符的唯一命名问题。比如在不同的命名空间实现相同名称的函数，这个函数在怎么表示呢？名称修饰技术用来生成唯一的标志符，保留命名空间、函数名、结构体名、类名以及参数类型等等信息。名称修饰和调用约定、编译器有关，应用最广泛的是C++的代码（尤其是混合C编译时）。比如`_ZN9wikipedia7article6formatEv`可以用来表示：

```c++
namespace wikipedia
{
    class article
    {
        public:
        std::string format();
    }
}
```

其中`_Z`是开头（下划线+大写字母在C中是保留的标志符，避免冲突），`N`表示是嵌套有命名空间和类名，随后的数字+字母中，数字表示长度，字母表示名称，并以`E`结束。之后的参数表示函数的参数类型，v为void。

## PE文件

PE（Portable Execution）文件是Windows系统使用的可执行文件格式。

* 可执行PE文件扩展名一般为exe，src
* 库文件扩展名一般为dll，ocx，cpl，drv
* 驱动程序文件扩展名一般为sys，vxd
* 对象文件扩展名一般为obj

### PE文件的数据节
* .text 代码节，存放二进制机器码
* .data 初始化数据节，如宏定义、全局变量、静态变量
* .idata 可执行文件使用的动态链接库等外部函数与文件，即输入表
* .rsrc 程序资源节，包括图标、菜单等

\#pragma data_seg()可以将代码任意部分编译到PE文件任意节，节名也可以自定义。


## 静态链接库与动态链接库

静态库的拓展名为`.a`或`.lib`；动态库的拓展名一般为`.so`或`.dll`

静态库编译时直接整合到目标程序中，编译成功后的可执行文件可以独立运行；动态库编译时可执行程序无法独立运行

静态库更新后需要更新整个目标程序；动态库更新后只需更换新的动态库即可

静态库编译命令：`gcc -c xx.c -o xx.o`，`ar crs libxx.a xx.o`；动态库编译命令：`gcc xx.c -o libxx.so -shared -fPIC`其中-fPIC表示使用相对位置

## gdb

添加多个符号表`add-symbol-file xxx addr`其中addr是代码段起始地址，xxx可以为sym文件，或elf文件等。变异时需要加上`-g`保留符号表(指定具体格式如`-g2 -gdwarf-2`)，可以逐个使用`add-symbol-file`，都添加进去。

使用`ulimit -c unlimited`设置不限制coredump文件大小，然后root用户`echo "core-%e-%p" > /proc/sys/kernel/core_pattern`设置保留程序名、pid，则对于编译时添加了`-g`选项的程序，其崩溃产生的coredump文件可以使用`gdb <程序名> <coredump文件名>`来寻找root cause。gdb内用where查看调用栈。

## 推荐阅读

[Linux 静态库 编译和使用](https://blog.csdn.net/houxian1103/article/details/122272516)
[Linux 动态库 编译和使用](https://houxian1103.blog.csdn.net/article/details/122272862)
[Makefile入门](https://dlonng.com/posts/makefile)
[Makefile官方文档](https://www.gnu.org/software/make/manual/make.html#Introduction)
[coredump文件基础用法](https://blog.51cto.com/u_16001762/6387467)