# Frama-C

## 简介

Frama-C 是一个专注于 C 语言的代码分析与验证框架，支持深度的语义分析和形式化验证。它的插件生态系统允许开发者对代码的逻辑行为进行建模，甚至可以验证特定代码区域是否满足预期的逻辑性质。使用Frama-C本质上是属于基于静态抽象解释的程序分析方法。

ACSL (ANSI/ISO-C Specification Language)是一种形式化语言，用于表达C程序的行为属性。通过向代码添加注解，允许构建包括前置条件、后置条件在内的函数合约，同时支持断言、循环等。

Framc-C/WP插件使得Frama-C能够验证带有ACSL注解的C程序。他使用了Hoare型的最弱前置条件计算，形式化证明了C代码中的ACSL属性。

特点：

* 提供抽象解释（Abstract Interpretation）来分析程序的执行路径和变量值范围
* 支持形式化验证，开发者可以用逻辑断言（如 Hoare 逻辑）注释代码
* 可以通过 ACSL（ANSI/ISO C Specification Language）对代码的逻辑性质进行描述，并验证代码是否符合这些性质
* 插件如 Value Analysis 可帮助理解变量值的可能范围，WP 插件则用于逻辑验证

使用场景:

* 希望对代码的逻辑行为进行数学上的严格验证，尤其适用于安全性要求高的场景（如关键系统）
* 需要分析特定代码区域的逻辑含义，通过形式化工具验证其正确性

局限性:

* 依赖专家经验、需要找到合适的抽象级别。抽象过度导致无法证明属性，抽象不足引发状态爆炸且成本较高
* 对于指针分析这一不可判定问题，实际指针分析算法需要在效率和精确度之间进行权衡
* 缺乏对污点值的识别，缺乏显式、隐式类型转换的区分，对变量区间收集过松，对某些数学函数区间手机不准确，导致误报
* 对复杂浮点表达式约束的求解能力不足，缺少部分定制化浮点异常检测逻辑，运算符处理不完全，缺乏跨翻译单元的浮点支持，导致漏报


官网资源: 

* [Frama-C](https://frama-c.com/index.html)
* [Frama-C/WP Tutorial](https://allan-blanchard.fr/publis/frama-c-wp-tutorial-en.pdf) 非常推荐阅读这个pdf，本文后续内容也是基于这个逻辑展开的

## 安装

Frama-C配合图形化界面最佳，首选Ubuntu Desktop。Windows下也可以使用WSL2，参考[官方说明](https://www.frama-c.com/html/get-frama-c.html)，如下：

```bash
# 1. Prepare opam installation
sudo apt update && sudo apt upgrade
sudo apt install make m4 gcc opam

# 2. opam setup
opam init --disable-sandboxing --shell-setup
eval $(opam env)
opam install -y opam-depext

# 3. Install graphical dependencies
opam depext --install -y lablgtk3 lablgtk3-sourceview3

# 4. Install Frama-C
opam depext --install -y frama-c

# 5. Install software kits
sudo apt install yaru-theme-icon

# On WSL2, run the GUI as:
GDK_BACKEND=x11 frama-c-gui 
```


对于服务器端Linux安装，也可以使用以下命令，然后`ssh -X`来提供图形化功能。

```bash
# all in root account
apt-get install opam
opam init
opam install frama-c

eval $(opam env) # 这个最好写到profile或者bashrc里，不然每次登录shell运行frama-c之前都要执行一遍

# 配置ivette
# 需预先准备nodejs == 20
wget https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz
# 随后解压缩并添加PATH即可
npm install --global yarn
ivette
```

安装结束后，更新prover：

```bash
why3 config detect

```

## Demo

首先准备如下的`main.c`文件，然后运行`frama-c -wp main.c`

```c title="main.c"
/*@
    requires \valid(a) && \valid(b);
    assigns *a, *b;
    ensures *a == \old(*b);
    ensures *b == \old(*a);
*/
void swap(int * a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

int main() {
    int a = 42;
    int b = 37;

    swap(&a, &b);

    //@ assert a == 37 && b == 42;

    return 0;
}
```

## 函数合约（Function Contract）

函数合约是frama-c的重要组成部分，使用ACSL语言描述了执行函数前预期的属性（precondition）和预期输出应当具备的属性（postcondition）。通过之前的例子可知，ACSL以注释的形式出现在源程序中，相比普通的注释多出了@符号。

### 后置条件（Postcondition）

后置条件postcondition由`ensures`关键字指定，比如下面的函数：

```c
/*@
    ensures \result >= 0;
    ensures (val >= 0 ==> \result == val ) &&
            (val <  0 ==> \result == -val);
*/
int abs(int val) {
    if (val < 0) return -val;
    return val;
}
```

ACSL每条语句也是以分号作为结束，且可以有多条ensures保证多种后置条件。此处的逻辑蕴含符`==>`表示“如果前面为真，则后面必定为真”。当然，如果前面为假，整个表达式为真，但后面内容可真可假。在frama-c中，自动进行`requires ==> ensures`与`assumptions ==> assertion`的验证。此处的`\result`是关键字，用于表示函数返回值。

### 断言（Assert）

使用`assert`可以保证程序在运行到指定位置时应当具备的属性，比如：

```c
/*@
    ensures \result >= 0;
    ensures (val >= 0 ==> \result == val ) &&
            (val <  0 ==> \result == -val);
*/
int abs(int val) {
    int __retres;
    if (val < 0) {
        /*@ assert rte: signed_overflow: -2147483647 <= val; */
        __retres = -val;
        goto return_label;
    }
    __retres = val;
    return_label: return __retres;
}
```

其中`rte:`和`signed_overflow:`是为规则添加的名称，可以自定义。

### 前置条件（Precondition）

前置条件precondition描述了函数执行前的约束，即仅在函数调用时刻检查是否成立，使用`requires`进行限定，比如：

```c
#include <limits.h> 

/*@
    requires INT_MIN < val;
    ensures positive_value: function_result: \result >= 0;
    ensures (val >= 0 ==> \result == val ) &&
            (val <  0 ==> \result == -val);
*/
int abs(int val) {
    if (val < 0) return -val;
    return val;
}

int foo(int a) {
    int b = abs(42);
    int c = abs(-42);
    int e = abs(INT_MIN); // LINE 1
    int d = abs(a); // LINE 2
}
```

和C不同，可以使用连续的运算符进行比较，比如，INT_MIN < val < 42是合法的。

!!! note
    有一点需要注意，这里会认为LINE 1有问题，但是LINE 2没问题；而交换LINE 1和LINE 2的位置，分析结果会变为两者都有问题。这是因为在顺序分析的过程中，一旦可以肯定地认为某处存在问题，那么后续一定不存在问题（即`F ==> F/T`恒成立）。在演绎推理中，如果前置条件成立、计算能够完成，则后置条件验证成立。否则，如果前置条件一定不成立，演绎结果为任何事情都可以发生，也包括False的后置条件。在计算abs(INT_MIN)的过程中，自动向假设里添加了False的assumption，导致后续的abs恒为合法。

### 指针（Pointer）

C语言中的指针是非常棘手的数据对象，在ACSL中也被特别对待。考虑下面的swap函数：

```c title="swap.c"
/*@
    requires \valid(a) && \valid(b);
    ensures *a == \old(*b) && *b == \old(*a);
*/
void swap(int * a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}
```

对于指针a、b，在ensures中使用\*a、\*b来获取对应内存的内容。requires中的`\valid`函数限定了指针必须是合法的，即在解引用时不会引发未定义行为。也可以传递多个指针，比如`\valid(p + (s .. e))`表示对于`[s, e]`中的所有整数`i`，有`p+i`是合法指针。此外，`\valid_read`表示内存可读，`\valid`要求内存可读写。



#### 内存历史记录

前文提到的`\old`是ACSL的内置逻辑函数，允许获取指定元素在函数调用执行前的值，且仅能在后置条件中出现。如果需要在别处使用，则需要`\at`关键字，用法是`\at(<variable>, <label>)`，返回结果是某个标签处的变量本身。比如：

```c
int a = 42;
Label_a:
a = 45;
//@ assert a == 45 && \at(a, Label_a) == 42;
```

除了使用C语言内置的标签，也可以使用ACSL内置的标签，包括：

* `Pre`/`Old`：函数调用执行前
* `Post`：函数调用执行后
* `LoopEntry`：循环入口处
* `LoopCurrent`：当前循环步的开始处
* `Here`：此处

其中，`Old`和`Post`只能用于后置条件。

举个例子：

```c
/*@ requires x + 2 != p; */
void example(int *x, int *p) {
    *p = 2;
    //@ assert x[2] == \at(x[2], Pre);
    //@ assert x[*p] == \at(x[*p], Pre);
}
```

这里虽然在执行assert时\*p == 2，但实际上后者处理的是`//@ assert x[*p] == \at(x[\at(*p, Pre)], Pre)`，而在Pre的位置，\*p的值还没有被赋值。所以前者可以被proved，后者不行。

#### 副作用

考虑下面的分析：

```c title="Side Effects"
int h = 42;
/*@
    requires \valid(a) && \valid(b);
    ensures *a == \old(*b) && *b == \old(*a);
*/
void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

int main() {
    int a = 37;
    int b = 91;

    //@ assert h == 42;
    swap(&a, &b);
    //@ assert h == 42;
}

```

分析结果表示，第二个assert无法通过检查。这是因为swap函数存在修改全局变量的可能（尽管实际上没有），即存在副作用。为了处理这种情况，使用后置条件`assigns`来声明函数执行过程中哪些非局部的元素（non-local elements）可能被修改。因此swap函数需要被重写为：

```c
/*@
    requires \valid(a) && \valid(b);
    assigns *a, *b;
    ensures *a == \old(*b) && *b == \old(*a);
*/
void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}
```

此外，也可以使用`assigns \nothing;`来强调函数是无副作用的。

??? abstract "Order 3 小练习：实现void order_3(int *a, int *b, int *c)的递增排序"
    ```c
    /*@
        requires \valid(a) && \valid(b) && \valid(c);
        requires \separated(a, b, c);
        assigns *a, *b, *c;
        ensures *a <= *b <= *c;
        ensures { *a, *b, *c } == \old({ *a, *b, *c});
        ensures \old(*a == *b == *c) ==> *a == *b == *c;
        ensures \old(*a == *b < *c || *a == *c < *b || *b == *c < *a) ==> *a == *b;
        ensures \old(*a == *b > *c || *a == *c > *b || *b == *c > *a) ==> *b == *c;
    */
    void order_3(int *a, int *b, int *c) {
        if (*a > *b) { int tmp = *b; *b = *a; *a = tmp; }
        if (*a > *c) { int tmp = *c; *c = *a; *a = tmp; }
        if (*b > *c) { int tmp = *b; *b = *c; *c = tmp; }
    }
    ```



#### 内存别名

内存别名即多个指针指向相同的地址。对于swap函数来说编写的规则仍然成立，但对于另外一些函数来说存在问题：

```c title="Memory Location Separtion (Memory Alias)"
/*@
    requires \valid(a) && \valid_read(b);
    assigns *a;
    ensures *a == \old(*a) + *b;
    ensures *b == \old(*b);
*/
void incr_a_by_b(int *a, int const *b) {
    *a += *b;
}

```

此处不能保证`*b == \old(*b)`，因为如果a和b指向相同地址，执行后\*b也会被修改。因此，使用`\separated(p1, ... pn)`来声明这些指针是不重叠的，即添加`requires \separated(a,b);`。
    
当然，这个例子没有考虑overflow的问题，在实际程序还需要考虑比如`requires INT_MIN < *a + *b < INT_MAX;`之类的限定（注意include limits.h）。

### 行为（Behaviors）

函数有时会根据不同的输入而表现出不同的行为，比如根据指针是否为NULL而执行不同的路径。通过`behavior`关键字来描述不同的情况，`assumes`语句来刻画输入，可以分别具有不同的后置条件。最后利用WP来检查行为是否互斥（`disjoint`）与完备（`complete`）。

互斥即指各个behavior之间不存在交集，完备即指所有behaviors一起描述了所有可能的情况。即“不重不漏”。

以之前的abs函数举例：

```c title="Behaviors for abs"
#include<limits.h>

/*@
    requires val > INT_MIN;
    assigns \nothing;
    ensures \result >= 0;
    behavior pos:
        assumes 0 <= val;
        ensures \result == val;
    behavior neg:
        assumes val < 0;
        ensures \result == -val;
    complete behaviors;
    disjoint behaviors;
*/
int abs(int val) {
    if (val < 0) return -val;
    return val;
}

```

注意此处的`ensures \result >= 0;`即成为全局后置条件。此外需要注意这里的`assigns \nothing`表示所有的behavior都不会产生副作用。目前WP似乎不支持处理每个assumes里各自assigns，代替方法是像例子里这样设置全局assigns，然后在assumes里用`\old`来对那些没有修改的变量添加后置条件。

!!! note
    使用behaviors可以简化函数规则编写，但是手工实现满足不重不漏的规则是tedious且error-prone的。

### WP模块化（WP Modularity）

通常的程序往往存在函数之间的互相调用，比如A调用B，B又调用C。那么要证明函数A，需要证明函数B、C。比如，对于下面的函数：

```c title="max_abs.c"
int max_abs(int a, int b) {
    int abs_a = abs(a);
    int abs_b = abs(b);
    return max(abs_a, abs_b);
}
```

需要编写三个函数合约。通常，我们将函数合约放到头文件中（WP在需要在函数调用时获取合约），从而使其在别的文件中调用时能够复用函数合约。在进行验证时，首先确保前置条件合法性（因此调用是合法的），然后验证后置条件的合法性。因此，可以组织以下文件架构：

=== "main.c"
    ```c
    #include<limits.h>
    #include "max_abs.h"
    #include "abs.h"
    #include "max.h"
    int max_abs(int a, int b) {
        int abs_a = abs(a);
        int abs_b = abs(b);
        return max(abs_a, abs_b);
    }
    ```
=== "max_abs.h"
    ```c
    #ifndef _MAX_ABS
    #define _MAX_ABS
    int max_abs(int a, int b);
    #endif
    ```
=== "abs.h"
    ```c
    #ifndef _ABS
    #define _ABS
    #include<limits.h>
    /*@
        requires val > INT_MIN;
        assigns \nothing;
        ensures \result >= 0;
        behavior pos:
            assumes 0 <= val;
            ensures \result == val;
        behavior neg:
            assumes val < 0;
            ensures \result == -val;
        complete behaviors;
        disjoint behaviors;
    */
    int abs(int val);
    #endif
    ```
=== "abs.c"
    ```c
    #include "abs.h"
    int abs(int val) {
        if (val < 0) return -val;
        return val;
    }
    ```
=== "max.h"
    ```c
    #ifndef _MAX
    #define _MAX
    #endif
    ```
=== "max.c"
    ```c
    #include "max.h"
    extern int max(int a, int b);
    ```

在Framc-C中，如果函数A内部依赖函数B，在证明函数A的时候并不会去自动验证函数B，而是默认函数B是可证明的（provable），这提供了很好的灵活性，即便没有函数B的源码（通常是外部库）也支持验证函数A。也就是说我们选择“相信”函数B。

## <ruby>循环<rt>Loops</rt><ruby>

程序中的循环结构需要特殊对待，也是抽象解释非常重要的组成部分。我们需要一种<ruby>规则<rt>rule</rt><ruby>，从给定的一个指令序列和后置条件中确定前置条件。由于无法预先确定循环执行次数，因此无法确定有多少变量被修改。从归纳推理


## 插件

Frama-C依赖丰富的插件提供分析功能。因此需要研究现状与不足，否则科研工作会变成工程性的插件开发。可以在[这里](https://frama-c.com/html/documentation.html)检视现有插件手册。

**Frama-C** 是一个强大的程序分析框架，主要用于验证和分析 C 程序的安全性和正确性。它的功能是通过一系列 **插件** 来实现的。这些插件负责不同的分析任务，满足不同的需求。以下是 Frama-C 的一些关键插件及其功能简介：



### WP（Weakest Precondition）

**功能**：
- 验证程序的功能性规范（ACSL 注释中的 `requires`、`ensures` 等）。
- 使用逻辑推理工具（如 Alt-Ergo、Z3 等外部证明器）尝试证明程序的正确性。
- 检查 `//@ assert` 和函数契约是否满足。

**适用场景**：
- 证明程序满足功能性规范。
- 验证关键算法的正确性。


### EVA（Evolved Value Analysis）

**功能**：
- 进行值分析，推断程序中每个变量的可能取值范围（符号执行）。
- 检查运行时错误（如溢出、数组越界、空指针解引用等）。
- 提供程序状态的抽象信息（如变量的值域）。

**适用场景**：
- 静态检查潜在的运行时错误。
- 获取程序变量的可能取值范围。

### RTE（Runtime Errors）
**功能**：
- 自动插入运行时断言到程序中。
- 检测可能的运行时错误，包括：
  - 数组越界。
  - 除以零。
  - 指针解引用相关的错误。

**适用场景**：
- 检查运行时错误的风险。
- 补充其他插件（如 EVA 和 WP）的分析能力。



###  ACSL Parser 
**功能**：
- 解析 ACSL（ANSI/ISO C Specification Language）注释，提取契约信息。
- 将 ACSL 规范传递给其他插件（如 WP 或 EVA）进行验证。

**适用场景**：
- 用于基于规范的程序验证。
- 配合 WP 插件验证程序契约。



###  Slicing 
**功能**：
- 动态程序切片（Program Slicing）。
- 根据用户定义的关注点（如某些变量或代码段），提取程序的最小化子集。
- 删除与分析目标无关的代码。

**适用场景**：
- 简化大型程序的分析。
- 聚焦于程序中的某些关键路径。



###  PDG（Program Dependence Graph）
**功能**：
- 生成程序依赖图，展示变量、语句之间的依赖关系。
- 识别数据依赖和控制依赖。

**适用场景**：
- 可视化程序的依赖关系。
- 用于代码优化或漏洞挖掘。



###  Metrics 
**功能**：
- 提供程序的静态代码度量指标，包括：
  - 行数、函数数。
  - 循环复杂度（Cyclomatic Complexity）。
  - 数据流复杂度。

**适用场景**：
- 获取代码的复杂度信息。
- 评估代码质量。



###  Impact（影响分析）
**功能**：
- 分析代码修改的影响范围。
- 识别代码中哪些部分会受到特定修改的影响。

**适用场景**：
- 软件维护过程中评估代码修改的影响。
- 确定需要重新测试的代码区域。



###  Invariant 
**功能**：
- 自动计算或验证程序中可能的循环不变式。
- 与 WP 插件配合使用，用于证明带有循环的程序的正确性。

**适用场景**：
- 验证复杂循环的正确性。
- 自动推导或手动检查不变式。



###  Aoraï 
**功能**：
- 基于自动机验证程序的行为。
- 通过将程序的行为与用户定义的状态机模型进行匹配，验证程序的时序属性。

**适用场景**：
- 验证程序的控制流是否符合预期。
- 检查时序性错误（如死锁）。



###  E-ACSL 
**功能**：
- 将 ACSL 规范转换为 C 代码中的运行时检查。
- 在运行时验证程序是否符合指定的 ACSL 规范。

**适用场景**：
- 动态验证 ACSL 规范（基于程序运行时的实际行为）。
- 在测试阶段捕获规范违背。



###  From 
**功能**：
- 进行数据依赖分析，确定变量的值来源于哪些输入。
- 构建变量的依赖链。

**适用场景**：
- 分析变量的依赖路径。
- 安全分析中追踪敏感数据的流动。



###  Loop Unroll 
**功能**：
- 对循环进行展开，生成等价的、无循环的代码。
- 帮助分析循环行为。

**适用场景**：
- 简化循环分析（特别是对非复杂循环）。
- 与 WP 插件配合使用。



###  Constants 
**功能**：
- 分析程序中的常量表达式。
- 识别哪些变量的值是固定不变的。

**适用场景**：
- 优化程序性能。
- 辅助静态分析。



###  Ptests 
**功能**：
- 自动生成测试用例，覆盖指定的程序路径。
- 提高程序的测试覆盖率。

**适用场景**：
- 自动化生成程序的测试用例。
- 提高测试的效率和覆盖率。



### **总结**

Frama-C 的插件设计非常灵活，每个插件关注特定的分析任务。以下是一些典型应用场景和推荐插件：

| **应用场景**                 | **推荐插件**                    |
|--|--|
| 功能性验证                  | WP、ACSL Parser               |
| 运行时错误检测              | EVA、RTE                      |
| 数据依赖或影响分析          | From、Impact                  |
| 代码复杂度分析              | Metrics                       |
| 时序性行为验证              | Aoraï                         |
| 动态验证（运行时检查）       | E-ACSL                        |
| 程序切片                   | Slicing                       |
| 自动化测试用例生成          | Ptests                        |

这些插件可以单独使用，也可以组合使用，以满足复杂的分析需求。然而，provers只能简单回答“yes”、“no”、“unknown”的结果，不能具体给出“no”或者“unknown”的原因。