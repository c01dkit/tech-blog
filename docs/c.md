# C语言

## 根据结构体成员取结构体首地址

```c
member_address - &(((TYPE *)0)->member);
```

后半部分看似会解引用0地址而crash，但编译器会优化为直接计算member的offset。参见kernel代码常用的container_of。

## 编译时确定链接库

使用-l指定链接库，注意去掉库文件的lib开头和.so结尾。编译时，注意把库放在整个命令的结尾，否则可能提示库函数未定义。

比如`gcc main.c -lcapstone`不会报错，`gcc -lcapstone main.c`会提示报错。（假设这里main.c调用了capstone的库函数）