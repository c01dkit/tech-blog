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

// 使用命名空间内的函数，需要指定 命名空间::
namespace_name::namespace_func;

// using指令，则之后使用该命名空间内的函数不需要加 命名空间::
using namespace namespace_name;
namespace_func;

//全局变量和局部变量冲突时::val表示全局变量
::global_val;
local_val;
```
## 输入与输出

使用iostream头文件引入输入输出。

* cin 标准输入流
* cout 标准输出流
* cerr 非缓冲标准错误流
* clog 缓冲标准错误流

```cpp
#include <iostream>
using namespace std;
int main() {
    char a[10];
    cin >> a;
    cout << a;
}

```
## 变量、常量与类型限定符

基本数据类型类似C语言，此外还包括`bool`等。字符类型除了1字节的`char`，还包括`wchar_t`（宽字符，占2或4字节）、`char16_t`、`char32_t`。

类型限定符包括`const`、`mutable`、`volatile`、`restrict`、`static`、`register`等，置于类型前。

!!! note
    * `mutable`在C++11支持
    * `register`在C++11失效，在C++17被弃用

* `const` 定义值不可被修改的变量，可以理解为维护对象的状态不发生改变
  * `const`成员函数内部，不能修改非静态成员变量的值
  * `const`对象只能调用`const`成员函数
* `mutable` 修饰类的成员变量，表示该变量可以被修改，即便被const修饰

```cpp
class Sample {
    public:
    int get_data() const { // const 成员函数内部不能修改任何非静态成员变量的值
        return __data;
    }
    void set_data(int new_value) const {
        __data = new_value; // 虽然是const 成员函数内部，但由于__data是mutable的，所以可以修改
    }
    private:
    mutable int __data;
}

int main () {
    const Sample obj; // const对象只能调用const函数
    obj.set_data(10);
    obj.get_data(); 
}
```

* `volatile` 暗示编译器该变量的值可能被外部硬件或其他线程修改（在不确定的时机被修改）
* `restrict` 暗示编译器该变量的值只能被这个指针访问
* `static` 定义静态变量
  * 对于全局变量而言，指定该变量作用域仅限于当前文件，不能被其他文件访问
  * 对于函数局部变量而言，在程序生命周期内保持值不被进出作用域而销毁
  * 对于类的成员变量而言，该成员不依赖具体的对象，而成为该类所有对象共享的变量
* `register` 暗示编译器该变量经常被使用，可以存储在寄存器中


## 指针与引用

## 函数模板与泛型编程


## 类与对象

### 类成员函数

类成员函数可以在类定义的内部进行定义，此时成员函数即为内联函数。也可以在类定义的外部进行定义，一般使用`返回值类型 类名::函数名(参数列表) {函数体}`的形式。

```cpp
class Sample {
    public:
    int sample1() {return 1;} // 在类内部定义函数实现
    int sample2(); // 在类外部定义函数实现
}

// 需要使用范围解析运算符::来指定哪个类
int Sample::sample2() {return 2;}
```

### 构造函数、拷贝构造函数、析构函数

类的构造函数在创建新的类对象是执行，名称与类名相同，没有返回值。一般用于为成员变量设置初始值。
构造函数中，使用初始化列表来对类成员进行赋值时，在构造函数定义的大括号前加上`: X(a)`，其中X是内部成员，a是构造函数的参数，实现将a赋给X。计算顺序是按类内的成员定义顺序，而不是按初始化列表的顺序来进行赋值。
拷贝构造函数一般用于根据已有的类对象，生成新的类对象，比如复制。如果类不包含指针或动态内存分配，可以不写，编译器会帮助生成；否则必须自己实现。
析构函数类似于构造函数，但函数名前加了~符号。它不能带有参数，也没有返回值，一般用于释放对象时进行资源释放。
析构函数都不需要显式调用。

```cpp
#include<iostream>
class Sample {
    public:
    void setData(int i);
    Sample(); // 构造函数
    Sample(int i); // 带参构造函数
    Sample(const Sample & obj); // 拷贝构造函数
    ~Sample(); // 析构函数
    private:
    int * data;
}

// 在类声明外部实现函数，则为非内联
Sample::Sample() {
    std::cout << "Construction" << std::endl;
    data = new int;
    *data = 0;
}

// 带初始化列表的构造函数
Sample::Sample(int i): data(i) {
    std::cout << "Construction with initial list" << std::endl;
    data = new int;
    *data = i;
}

// 拷贝构造函数定义
Sample::Sample(const Sample & obj) {
    std::cout << "Construction with another object" << std::endl;
    data = new int;
    *data = *obj.data;
}

// 析构函数定义
Sample::~Sample() {
    std::cout << "Deletion" << std::endl;
    delete data;
}

void Sample::setData(int i) {
    data = i;
}

int main () {
    Sample sample1;
    sample1.setData(1);
    Sample sample2(2);
    Sample sample3(sample1);
    Sample sample4 = sample3;
}
```

创建类的对象时，可以直接以`类名 对象名`的形式构建一个默认对象，或者`类名 对象名(参数列表)`构建一个带参数的对象，或者`类名 对象名=已有对象`、`类名 对象名(已有对象)`来用拷贝构造函数。注意不要直接调用构造函数本身，它没有返回值。

### 删除函数

在一些默认函数（比如拷贝构造函数）后加上`= delete`意为禁止该函数被调用。

```cpp
class Sample {
    Sample(const Sample &) = delete; // 禁止通过拷贝构造函数新建对象
    Sample &operator=(const Sample &) = delete; // 禁止通过赋值来拷贝对象
}
```

### explicit

如果一个构造函数只接受一个参数（或者是可以通过默认值变成只接受一个参数），它会被视为一个转换构造函数。这种构造函数允许通过隐式转换将其他类型的对象转换为当前类的对象，可能会产生不必要的行为。为了避免这种情况，使用explicit来显式创建对象。

=== "显式创建对象"
    ```cpp
    #include <iostream>
    using namespace std;
    class MyClass {
    public:
        explicit MyClass(int value) {
            cout << "Constructor called with value: " << value << endl;
        }
    };
    
    void print(const MyClass& obj) {
        cout << "print function called" << endl;
    }
    
    int main() {
        // print(42); // 错误，无法隐式转换
        print(MyClass(42)); // 必须显式创建对象
        return 0;
    }
    ```
=== "显式类型转换"
    ```cpp
    #include <iostream>
    using namespace std;

    class MyClass {
    public:
        explicit operator int() const {
            return 42;
        }
    };

    int main() {
        MyClass obj;
        // int value = obj; // 错误，无法隐式转换
        int value = static_cast<int>(obj); // 必须显式转换
        cout << "value = " << value << endl;
        return 0;
    }
    ```
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

### 类型别名

使用 `using NewType = OldType`为复杂类型构建简单别名，原理类似`typedef OldType NewType`，但表达更加清晰，而且支持泛型。

```cpp
template <typename T>
using Vec = std::vector<T>;

Vec<int> myVec; // 等价于 std::vector<int>
```

## C++14新特性

## C++17新特性

## C++20新特性