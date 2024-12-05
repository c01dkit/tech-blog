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

## LLVM IR

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

### 四大关键程序对象

根据LLVM分析的程序对象不同，可以按从大到小的顺序分为Module、Function、BasicBlock、Instruction四个等级。可以直接采用for循环遍历高等级对象的方法，获取其中的下一级对象。可见前文的项目例子。

#### llvm::Module

可以理解为对整个bc文件进行分析得到的结果，其中包含多个Function。

#### llvm::Function

#### llvm::BasicBlock

#### llvm::Instruction

```cpp
const llvm::Instruction I;
I.getOpcodeName(); // 获取操作符的字符串名称
I.getNumOperands(); // 获取操作数个数
I.getOperand(i); // 获取第i个操作数，返回llvm::Value*

I.hasMetaData(); // 检查当前指令是否附有metadata，比如调试信息
I.getMetaData("dbg"); // 获取当前指令的dbg调试信息
```

### 调试信息分析

[前文提到](#opaque-pointer)，在编译程序时添加`-g`选项，可以生成类似
