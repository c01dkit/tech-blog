# C语言

## 根据结构体成员取结构体首地址

```c
member_address - &(((TYPE *)0)->member);
```

后半部分看似会解引用0地址而crash，但编译器会优化为直接计算member的offset。