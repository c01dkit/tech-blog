# LLVM 学习

!!! note "叠个甲"
    本文内容是结合ChatGPT-4o-Latest模型、LLVM 15.0.7，在刚接触llvm的时候边学边写下的笔记，可能会出现纰漏。欢迎评论斧正！

## 快速上手

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


### 教学项目

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

opt是一个命令行工具，用于在LLVM IR层面上进行代码优化。 它可以应用各种各样的优化策略，如死代码消除、常量折叠等，以提高生成代码的效率。

LLVM Pass工作在LLVM IR文件的基础之上。IR包括ll（文本格式，便于人工阅读）和bc（字节码）两种形式。源码、IR、汇编代码的互相转化方法如下所示：

```
.c -> .ll: clang -emit-llvm -S a.c -o a.ll
.c -> .bc: clang -emit-llvm -c a.c -o a.bc
.ll -> .bc: llvm-as a.ll -o a.bc
.bc -> .ll: llvm-dis a.bc -o a.ll
.bc -> .s: llc a.bc -o a.s
```

### 可视化

`opt -p dot-cfg xxx.ll`可以将ll文件生成.dot文件，进一步用Graphviz的`dot xxx.dot -Tpng -o xxx.png`生成CFG图片。

### 项目例子

利用LLVM构建静态分析框架时，考虑用cmake来组织整个项目的编译。假设需要构建一个程序，它接收一个bc文件名作为参数，然后用两个pass来进行处理，打印出bc文件所包含的函数名，以及函数的参数个数，可以这么来组织项目：

=== "Makefile"
    ```makefile
    --8<-- "docs/assets/llvm/Makefile"
    ```
=== "src/CMakeLists.txt"
    ```makefile
    --8<-- "docs/assets/llvm/src/CMakeLists.txt"
    ```
=== "src/main.cpp"
    ```cpp
    --8<-- "docs/assets/llvm/src/main.cpp"
    ```
=== "src/PrintFunctionArgsPass.cpp"
    ```cpp
    --8<-- "docs/assets/llvm/src/PrintFunctionArgsPass.cpp"
    ```
=== "src/PrintFunctionArgsPass.hpp"
    ```cpp
    --8<-- "docs/assets/llvm/src/PrintFunctionArgsPass.hpp"
    ```
=== "src/PrintFunctionNamesPass.cpp"
    ```cpp
    --8<-- "docs/assets/llvm/src/PrintFunctionNamesPass.cpp"
    ```
=== "src/PrintFunctionNamesPass.hpp"
    ```cpp
    --8<-- "docs/assets/llvm/src/PrintFunctionNamesPass.hpp"
    ```


### 前端分析

`clang -Xclang -ast-dump -fsyntax-only sample.c`将源码解析为语法树。

## LLVM IR

### 基础指令

```c title="sample.c"
#include<stdio.h>

int main() {
    int a = 1, b = 2;
    if (a < b)
    {
        a = 1;
    } else {
        a = 2;
    }

    return 0;
}
```

运行`clang -S -emit-llvm -O0 test.c -o test.ll`后，上述代码生成下列ll文件：

```llvm
; ModuleID = 'test.c'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 1, ptr %2, align 4
  store i32 2, ptr %3, align 4
  %4 = load i32, ptr %2, align 4
  %5 = load i32, ptr %3, align 4
  %6 = icmp slt i32 %4, %5
  br i1 %6, label %7, label %8

7:                                                ; preds = %0
  store i32 1, ptr %2, align 4
  br label %9

8:                                                ; preds = %0
  store i32 2, ptr %2, align 4
  br label %9

9:                                                ; preds = %8, %7
  ret i32 0
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 15.0.7"}
```
target datalayout即[目标数据布局](https://llvm.org/docs/LangRef.html#data-layout)，指定了大小端、符号表命名格式、整型对齐格式等信息。
target triple即目标三元组，依次指定了CPU-vendor-OS，决定了生成目标程序的平台。
dso_local即[运行时抢占性修饰符](https://llvm.org/docs/LangRef.html#runtime-preemption-specifiers)，在生成动态链接库的时候直接调用对应函数，不在PLT表中进行搜索，可以提高运行效率。

* 使用`%xx`来指定引用变量，使用`@xx`来引用全局变量
* 使用`@name = global type value`定义全局变量，使用`@name = global constant type value`定义全局只读变量
* `value = alloca type, align n`声明栈上变量value指针，n字节对齐
* `store type value1, ptr value2, align n`将value1保存到value2的地址中，n字节对齐
* `value1 = load type, ptr value2, align n`从value2地址加载type类型数据到value1中，n字节对齐
* `value1 = icmp cmp type value2, value3`比较type类型的数据value2和value3的关系，将比较结果保存在value1中，这里的cmp可以包括eq、ne（相等与不相等），ugt、uge、ult、ule的无符号数比较，以及sgt、sge、slt、sle的有符号数比较
* `br i1 value1, label value2, label value3`检查bool类型的value1是否为真，若是则跳转到value2对应的位置，否则跳转至value3对应的位置
* `value1 = trunc type1 value2 to type2`将type1类型的value2截断成type2类型的value1
* `value1 = zext type1 value2 to type2`将type1类型的value2零扩展成type2类型的value1，零扩展即高位补0
* `value1 = sext type1 value2 to type2`将type1类型的value2符号扩展成type2类型的value1，符号扩展即高位补符号位
* `value1 = ptrtoint ptr value2 to i64`将指针类型的value2转化成整数，保存在value1中
* `value1 = inttoptr i64 value2 to ptr`将整数类型的value2转化成指针，保存在value1中
* `value = alloca [n x type]`定义一个数组，包含n个type类型的元素，注意这里是x不是*
* `value = type { type1, type2 }`定义一个结构体，注意这里的type是关键字
* `value1 = getelementptr typevalue, ptr value2, i64 index1, i32 index2`从typevalue类型的value2中，取下标index1的元素（若为0就表示直接使用指针本身进行索引）的第index2的成员（从0开始计数），保存到value1里。如果value1本身还是个数组，可以继续在getelementptr后面追加`i64 index3`来继续索引
* `value1 = extractvalue typevalue value2, index`假如聚合类型value2本身不是指针，则不使用getelementptr，而是extractvalue。从类型为typevalue的value2中取第index的字段赋值给value1（从0开始计数）
* `value1 = insertvalue typevalue value2, type value3, index`将typevalue类型的value2值的第index的成员（从0开始计数） 
* `value1 = select i1 value2, type1 value3, type2 value4`如果value2为真，将value3赋值给value1；否则将value4赋值给value1，类似三目运算
* `value1 = phi type [value2, block1], [value3, block2]`如果前一个block是block1，则给value1赋值type value2；如果前一个block是block2，则给value1赋值type类型的value3。这些block数量可以一直往后加，实现多分支赋值的功能

### LLVM IR 内置函数

#### Memory Use Markers

```llvm
; llvm.lifetime.start 声明了内存对象声明周期的开始，第一个参数是一个常量整数，表示对象的大小；如果对象大小可变，则为 -1。第二个参数是指向该对象的指针。
declare void @llvm.lifetime.start(i64 <size>, ptr nocapture <ptr>)
```

```llvm
; llvm.objectsize 内在函数旨在向优化器提供信息，以确定 a) 操作（如 memcpy）是否会溢出与对象对应的缓冲区，或 b) 不需要运行时检查溢出。此上下文中的对象意味着特定类、结构、数组或其他对象的分配。四个参数分别表示：对象指针；对象大小未知时函数应当返回0（若为true）还是-1（若为false）；NULL用作指针参数时函数应当返回0字节（若为false）或大小未知（若为true）；是否应在运行时评估该值。
declare i32 @llvm.objectsize.i32(ptr <object>, i1 <min>, i1 <nullunknown>, i1 <dynamic>)
declare i64 @llvm.objectsize.i64(ptr <object>, i1 <min>, i1 <nullunknown>, i1 <dynamic>)


```

### 抢占性

对于C比较常用的extern、static，假如有以下定义：

=== "C源代码变量定义"
    ```c
    int a; // 当前文件的全局变量
    extern int b; // 外部文件的全局变量
    static int c; // 仅限当前文件的全局变量
    void d(void); // 外部文件函数
    void e(void) {} // 当前文件函数
    static void f(void) {} // 仅限当前文件的函数
    ```
=== "LLVM IR表现形式"
    ```llvm
    @a = dso_local global i32 0, align 4
    @b = external global i32, align 4
    @c = internal global i32 0, align 4
    declare void @d()
    define dso_local void @e() {
    ret void
    }
    define internal void @f() {
    ret void
    }
    ```



### opaque pointer

不透明指针即不关心具体的指针类型，而使用`ptr`来取代之前的具体类型比如`i32*`。不透明指针在LLVM 15成为默认选项，并在LLVM 17移除透明指针。对于允许禁用不透明指针的LLVM版本而言，在命令行编译时，可以添加`-Xclang -no-opaque-pointers`来保留显式类型。cmake可以使用`-DCLANG_ENABLE_OPAQUE_POINTERS=OFF`。

在启用不透明指针的情况下，可以在编译时启用`-g`参数，使得可以从编译器生成的调试信息中恢复出指针的类型信息。

=== "sample1.c"
    ```c
    --8<-- "docs/assets/llvm/testsuite/sample1.c"
    ```
=== "原始IR"
    ```llvm
    --8<-- "docs/assets/llvm/testsuite/sample1.ll"
    ```
=== "-Xclang -no-opaque-pointers"
    ```llvm
    --8<-- "docs/assets/llvm/testsuite/sample1-no-opaque-pointer.ll"
    ```
=== "-g"
    ```llvm
    --8<-- "docs/assets/llvm/testsuite/sample1-g.ll"
    ```
=== "-Xclang -no-opaque-pointers -g"
    ```llvm
    --8<-- "docs/assets/llvm/testsuite/sample1-g-no-opaque-pointer.ll"
    ```

结合调试元数据（如 DILocalVariable 和 DIType）以及高层接口（如函数签名）可以恢复指针类型。但如果没有调试信息，恢复类型会变得困难，只能通过间接手段推断指针类型。

## LLVM API

可以参考[这里](https://llvm.org/doxygen/namespacellvm.html)快速搜索所有API。

### 头文件架构

关注之前下载的llvm-project-xx.x.x.src目录下的llvm/include/llvm文件夹，里面包含`ADT`、`IR`、`IRReader`等各种头文件，从中可以了解如何调API。以15.0.7版本为例，目录架构如下：

```shell title="tree ./llvm-project-15.0.7.src/llvm/include/llvm -LF 1"
./
├── ADT/
├── Analysis/
├── AsmParser/
├── BinaryFormat/
├── Bitcode/
├── Bitstream/
├── CMakeLists.txt
├── CodeGen/
├── Config/
├── DebugInfo/
├── Debuginfod/
├── Demangle/
├── DWARFLinker/
├── DWP/
├── ExecutionEngine/
├── FileCheck/
├── Frontend/
├── FuzzMutate/
├── InitializePasses.h
├── InterfaceStub/
├── IR/
├── IRReader/
├── LineEditor/
├── LinkAllIR.h
├── LinkAllPasses.h
├── Linker/
├── LTO/
├── MC/
├── MCA/
├── module.extern.modulemap
├── module.install.modulemap
├── module.modulemap
├── module.modulemap.build
├── ObjCopy/
├── Object/
├── ObjectYAML/
├── Option/
├── PassAnalysisSupport.h
├── Passes/
├── Pass.h
├── PassInfo.h
├── PassRegistry.h
├── PassSupport.h
├── ProfileData/
├── Remarks/
├── Support/
├── TableGen/
├── Target/
├── Testing/
├── TextAPI/
├── ToolDrivers/
├── Transforms/
├── WindowsDriver/
├── WindowsManifest/
├── WindowsResource/
└── XRay/

43 directories, 13 files

```

#### Pass.h

LLVM Pass的基础是一个个pass，比如自己写一个类继承`llvm::ModulePass`，在内部覆写`runOnModule`函数。而ModulePass又是继承自`llvm::Pass`的，也就是直接来自头文件目录下的`Pass.h`文件。这个头文件大致结构如下：

```cpp title="Pass.h"
#ifndef LLVM_PASS_H
#define LLVM_PASS_H
#include <string>

namespace llvm {

class AnalysisResolver;
class AnalysisUsage;
class Function;
//   ...

// AnalysisID - Use the PassInfo to identify a pass...
using AnalysisID = const void *;

/// Different types of internal pass managers.
enum PassManagerType {
//   ...
};

// Different types of passes.
enum PassKind {
//   ...
};

/// This enumerates the LLVM full LTO or ThinLTO optimization phases.
enum class ThinOrFullLTOPhase {
//   ...
};

class Pass {
// ...
};

class ModulePass : public Pass {
// ...
};

class ImmutablePass : public ModulePass {
// ...
};

class FunctionPass : public Pass {
// ...
};

} // end namespace llvm

// Include support files that contain important APIs commonly used by Passes,
// but that we want to separate out to make it easier to read the header files.
#include "llvm/PassAnalysisSupport.h"
#include "llvm/PassSupport.h"

#endif // LLVM_PASS_H

```

可见，ModulePass和FunctionPass两个类直接继承了Pass。ImmutablePass直接继承了ModulePass。

### bc文件读取与解析

通过`#include "llvm/IRReader/IRReader.h"`使用`std::unique_ptr<Module> parseIRFile(StringRef Filename, SMDiagnostic &Err, LLVMContext &Context)`来获取bc文件的指针，随后可以在自定义方法如`myParseFunc(const Module &Mod)`中遍历指针内容（即解引用），得到llvm::Module下一层的llvm::Function。类似地，对llvm::Function进一步遍历可以获取llvm::BasicBlock，再进一步遍历可以获取llvm::Instruction，每一级可以调用相关API函数。

### 关键程序对象

根据LLVM分析的程序对象不同，可以按从大到小的顺序分为Module、Function、BasicBlock、Instruction四个等级。可以直接采用for循环遍历高等级对象的方法，获取其中的下一级对象。可见前文的项目例子。如果是指针，可以用getBasicBlockList()、getInstList()等函数

#### llvm::Module

可以理解为对整个bc文件进行分析得到的结果，其中包含多个Function。

#### llvm::Function

#### llvm::BasicBlock

```cpp
const llvm::BasicBlock BB;
BB.getTerminator(); // 获取基本块最后一条指令
BB.printfAsOperand(errs()); // 获取label %num 即BB的编号
```


#### llvm::Instruction

```cpp
const llvm::Instruction I;
I.printAsOperand(errs()); // 将指令作为操作数打印，即打印返回值
I.print(errs()); // 打印指令本身，包括操作符、操作数等，不包括返回值
I.getOpcodeName(); // 获取操作符的字符串名称
I.getNumOperands(); // 获取该指令的操作数个数
I.getOperand(i); // 获取第i个操作数，返回llvm::Value*
I.getNumUses(); // 获取该指令返回值被其他指令使用的次数
I.users(); // 获取该指令返回值被其他指令使用的迭代器，通过const User* U : I.users()可以进行遍历
I.hasMetaData(); // 检查当前指令是否附有metadata，比如调试信息
I.getMetaData("dbg"); // 获取当前指令的dbg调试信息

const llvm::BranchInst* BI = dyn_cast<BranchInst>(&I); // BranchInst继承Instruction
BI.getOperand(i); // BranchInst的getOperand返回的似乎不是操作数
BI.getSuccessor(0); // 对于条件跳转，获取true时的后继基本块
BI.getSuccessor(1); // 对于条件跳转，获取false时的后继基本块

```



### 调试信息分析

[前文提到](#opaque-pointer)，在编译程序时添加`-g`选项，也可以从调试信息中恢复部分类型信息。

### 命令行参数处理

引入`#include "llvm/Support/CommandLine.h"`后，可以使用`cl::opt`类来处理命令行参数，供程序使用。可以看下面的例子：

```cpp
#include "llvm/Support/CommandLine.h"

using namespace llvm;

// 将命令行中的before跟随的字符串和BeforeFile变量绑定，debug-level跟随的整数和DebugLevel变量绑定，默认值2
// ./a.out --before=xxxx --debug-level=xxxx 来执行程序
static cl::opt<std::string> BeforeFile("before", cl::desc("Path to before-bug.bc"), cl::Required);
static cl::opt<int> DebugLevel("debug-level", cl::desc("Path to after-bug.bc"), cl::init(2));

// 除了指定命令行选项，也可使用非选项式
static cl::opt<int> AdditionalDescription(cl::Positional, cl::desc("Additional Description"), cl::value_desc("Description for value"));

int main(int argc, char **argv) {
  cl::ParseCommandLineOptions(argc, argv, "description"); // description为可选的描述字符串
  // 随后可以使用BeforeFile和DebugLevel两个变量
}
```


## 参考文章

1. [LLVM IR入门指南](https://evian-zhang.github.io/llvm-ir-tutorial/01-LLVM%E6%9E%B6%E6%9E%84%E7%AE%80%E4%BB%8B.html)
2. [LLVM API参考手册](https://llvm.org/docs/LangRef.html)