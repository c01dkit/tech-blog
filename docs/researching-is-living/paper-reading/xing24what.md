# 论文阅读

> What IF Is Not Enough? Fixing Null Pointer Dereference With Contextual Check

## Abstract

Null pointer dereference (NPD) errors pose the risk of unexpected behavior and system instability, potentially leading to abrupt program termination due to exceptions or segmentation faults. When generating NPD fixes, all existing solutions are confined to the function level fixes and ignore the valuable intraprocedural and interprocedural contextual information, potentially resulting in incorrect patches. In this paper, we introduce CONCH, a novel approach that addresses the challenges of generating correct fixes for NPD issues by incorporating contextual checks. Our method first constructs an NPD context graph to maintain the semantics related to patch generation. Then we summarize distinct fixing position selection policies based on the distribution of the error positions, ensuring the resolution of bugs without introducing duplicate code. Next, the intraprocedural state retrogression builds the if condition, retrogresses the local resources, and constructs return statements as an initial patch. Finally, we conduct interprocedural state propagation to assess the correctness of the initial patch in the entire call chain. We evaluate the effectiveness of CONCH over two real-world datasets. The experimental results demonstrate that CONCH outperforms the SOTA methods and yields over 85% accurate patches.

## 概览

这篇工作针对空指针解引用（NPD）修复质量低的现状，设计了一种上下文感知的检测与修复机制Conch。主要适用于解决需要插入if检查的修复场景。

## 背景

### 重要性

NPD致使程序崩溃，可能导致系统级崩溃。如果被攻击者恶意利用，也可以实现未授权代码执行、DoS等恶意行为。

### 必要性

现有工作大多遵照生成-验证的修复范式，并自动生成测试样例。现存工作局限于函数级修复，忽视了上下文中的过程内与过程间的信息。现有工作中，忽视过程内的上下文信息可能会导致内存和锁资源的占用，且缺少考虑过程间信息的工作。

### 挑战

1. 如何选择合适的修复位置，避免冗余patch（设计NPD Context Graph，仅保留和补丁生成相关的语义信息，确认null和error的位置和相应的path，然后设计4中修复位置选择策略避免冗余修复）
2. 如何通过过程内状态回退来保证函数内修复的正确性，从而构建初始补丁（主要包括检查被调函数异常处理情况、释放已分配内存）
3. 如何指导过程间状态传播，比如重置全局变量与函数参数（从函数入口到异常处理检查需要重置的全局变量、从返回值寻找主调函数的错误处理，递归查找）

## 设计

主要分为四个步骤：控制流图构建、确定修复位置、过程内状态回退、过程间状态传播。

### NPD Context Graph Construction

针对函数构建过程内的控制流图。为了避免路径爆炸，仅考虑one-hop的直接函数跳转。通过指针的赋值处和使用处确定“null position”和“error position”。随后从函数入口点到error position对过程内控制流图进行精简，并将和过程间控制流图建立关联。

### Path-sensitive Fixing Position Selection

这一步的目的是确认该在null position到error position之间何处进行fix，避免重复patch。这里主要根据null position和error position的数量关系（一对一、一对多、多对一、多对多）来确定fix position更靠近null position还是error position。

### Intraprocedural State Retrogression

首先通过内部状态回退实现初始patch。这一过程主要分三步：
1. 确定if语句的条件体所使用的checked variable和checked value，通过模仿附近的error-handling来实现。这里作者提出的一个点在于，判断if该用相等还是不相等也是存在挑战的
2. 确定局部变量的回退，也就是从函数入口到if判断前是否存在上锁和内存分配。如果有，就在if中进行释放。加解锁、内存申请释放函数对是通过关键字在CVE记录中检索，加上手工确认，形成字典对
3. 确定返回值，先假定返回一个和函数返回值相同的类型的值，形成初始补丁。此外，并非所有的if检查失败都要return，也可能continue或者break

### Interprocedural State Propagation

处理if返回值的问题，逐层找到caller里相关的error-handling语句，来推断该返回值，并可能将先前void的返回值类型调整为int

### 相关概念

Separation Logic 是计算机科学领域中一种用于形式化验证程序行为的逻辑系统，特别适用于分析和推理具有指针和可变内存的程序。它通过引入一种新的逻辑框架，使得对复杂的内存操作（例如堆操作）的推理更加简洁和直观。

## 一些点

* 静态分析怎么确定null pointer？这个不是运行时确定的吗？还是说所有用到指针的地方都是？
* 从caller相关的error-handling来推断返回值有点太过粗暴了。
* 仅仅从单一文件（以及相关#include）作为上下文，涉及的范围有点狭小了。如果相同的问题在两个毫无关联的文件中存在，其中一个已由开发人员正确修复，这一信息无法传达到另一个文件中，从而导致修复失败。