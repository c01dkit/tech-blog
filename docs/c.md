# C语言

## 根据结构体成员取结构体首地址

```c
member_address - &(((TYPE *)0)->member);
```

后半部分看似会解引用0地址而crash，但编译器会优化为直接计算member的offset。参见kernel代码常用的container_of。

## 动态链接库

**编译动态链接库本身**

使用gcc编译出动态链接库：

```shell
gcc <source C file> -shared -fPIC -o lib<source>.so
```

**编译原项目时指定动态链接库**

使用-l指定加载链接库，注意去掉库文件的lib开头和.so结尾。编译时，注意把库放在整个命令的结尾，否则可能提示库函数未定义。

比如`gcc main.c -lcapstone`不会报错，`gcc -lcapstone main.c`会提示报错。（假设这里main.c调用了capstone的库函数）

如果动态链接库不在默认的系统库中，可以添加`-L`来指定动态链接库的保存位置。

**运行项目时加载动态链接库**

即便编译成功，运行可能报错。搜索顺序为：

1. 在编译时添加`-Wl,-rpath=xxx`来指定运行时所需的动态库文件
2. 在环境变量`LD_LIBRARY_PATH`指定的目录中搜索
3. 在`/etc/ld.so.conf`给出的目录中搜索
4. 在默认的搜索路径`/lib`、`/lib64`、`/usrlib`、`/usrlib64`等搜索

## 赋值


初始化数组，可以连续赋值

```C
int arr[10] = {
    [0]       = 1,
    [1 ... 4] = 2,
    [5 ... 7] = 4,
};
```

数组在定义的同时进行部分初始化时，未被赋值的元素都会按照静态变量进行处理，即默认置零，即便`int a[10] = {};`没有显式初始化任何值。

初始化结构体或联合，可以一起赋值


```C

struct test {
    int a;
    int b;
    int c;
    int d;
};

int main(
    int argc, 
    char const *argv[]
    )
{
    struct test t = {
        .a = 1,
        .b = 2,
        .c = 3,
        .d = 4,
    };

    return 0;
}

```