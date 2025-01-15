# Frama-C

## 简介

Frama-C 是一个专注于 C 语言的代码分析与验证框架，支持深度的语义分析和形式化验证。它的插件生态系统允许开发者对代码的逻辑行为进行建模，甚至可以验证特定代码区域是否满足预期的逻辑性质。

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

* 学习成本较高，需要理解形式化验证的概念
* 对代码规模较大的项目可能需要较多时间配置分析

官网资源: 

* [Frama-C](https://frama-c.com/index.html)

## 安装

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

## Demo

```c title="main.c"
/*@
    requires \valid(a) ** \valid(b);
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