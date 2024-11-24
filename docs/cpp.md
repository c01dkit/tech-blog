# C++

## STL

### vector动态数组

`vector` 动态数组可以随机访问，其大小由系统自动管理。

```cpp
#include<vector>

// 声明与初始化
std::vector<int> vec1;
std::vector<int> vec2(3); // 指定长度，默认初始化
std::vector<int> vec3(3, 10); // 指定长度和默认值
std::vector<int> vec4 = {1,2,3,4} // 列表进行初始化

// 使用方法
vec.push_back(val); // 传递引用
vec.pop_back();
vec.at(pos);  // 有边界检查
vec[1];  // 无边界检查
vec.clear(); // 清空
vec.front(); // 返回第一个元素
vec.back(); // 返回最后一个元素
vec.data(); // 返回底层数组指针
vec.size();
vec.capacity();
vec.reserve(n); // 预留n个元素空间
vec.resize(n);
vec.insert(pos, val);
vec.erase(pos);
vec.begin(); // 起始迭代器
vec.end(); // 结束迭代器

// 遍历方法
for (int i = 0; i < vec.size(); i++) { x = vec[i] ;}
```

### deque双端队列

`deque` 双端队列可以随机访问，其大小由系统自动管理。

```cpp
#include<deque>

// 声明与初始化
std::deque<int> deque;
std::deque<int> deque(3); // 指定长度，默认初始化
std::deque<int> deque(3, 10); // 指定长度和默认值
std::deque<int> deque = {1,2,3,4} // 列表进行初始化

// 使用方法
deque.push_back(val); // 传递引用
deque.pop_back();
deque.push_front(val);
deque.pop_front();
deque.at(pos);  // 有边界检查
deque[1];  // 无边界检查
deque.clear(); // 清空
deque.front(); // 返回第一个元素
deque.back(); // 返回最后一个元素
deque.size();
deque.capacity();
deque.reserve(n); // 预留n个元素空间
deque.resize(n);
deque.insert(pos, val);
deque.erase(pos);
deque.swap(other_deque) // 交换两个deque内容
deque.begin(); // 起始迭代器
deque.end(); // 结束迭代器
```


## 头文件与命名空间

命名空间用于处理不同库中的同名函数、类与变量，相当于定义上下文。

```cpp
// 命名空间定义
namespace namespace_name {
    // 代码声明
}

// 命名空间使用
namespace_name::namespace_func;

// using指令
using namespace namespace_name;
namespace_func;

//全局变量和局部变量冲突时::val表示全局变量
::global_val;
local_val;
```
## 输入与输出

## 基本数据类型与变量

## 常量与类型推导

## 指针与引用

## 函数模板与泛型编程


## 类与对象

## 封装

## 继承

## 多态

## 运算符重载

## 静态成员变量与静态成员函数

## 常量成员函数

## this指针

## 对象的深拷贝与浅拷贝

## 模板编程


## 智能指针


## C++11新特性

## C++14新特性

## C++17新特性

## C++20新特性