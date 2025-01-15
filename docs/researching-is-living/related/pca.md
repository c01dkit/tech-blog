# 补丁正确性评估

## 自动化修复中的补丁正确性评估工作

补丁正确性评估（Patch Correctness Assessment，PCA）工作已有不少了，主要解决自动化程序修复（Automated Program Repair，APR）过程中遇到的过拟合问题（overfitting-problem）。目前主要有两种类型：incomplete fixing和regression introduction。在TOSEM 2024一篇suvey中(1)对其进行定义：
{ .annotate }

1.  Patch Correctnes Assessment: A Survey 

* Incomplete Fix: This kind of overfitting patch repairs some incorrect behaviors of the buggy program without breaking correct behaviors, but there are still incorrect behaviors not been repaired yet.
* Regression Introduction: This kind of overfitting patch breaks correct behaviors of the buggy program though it repairs some of or even all the existing incorrect behaviors.

可能会带来的后果：

1. 未完全的修复
2. 破坏其他函数功能
3. 短视的修复（Shortcut patch）
4. 隐藏漏洞

具体如何用PCA来解决overfitting problem？

* 有oracle：一般用于评估APR工作，不适用于真实场景
* 无oracle
  * 动态方法：利用运行时信息、测试样例增广、混合技术
  * 静态方法：利用代码意图、人类反馈、手工构造特征、自动学习特征、将原程序视作partial specification、利用natualness

一些启发式的方法，但也有其局限性：
* 正确的补丁不应当引入新bug，说明修复前后的改动不应该过大。不过linux kernel中有很多补丁甚至是通过重构来实现的。

LLM4PatchCorrect(1)利用大模型完成PCA工作，优势是对不同类型的APR泛化性好。
{ .annotate }

1.  原文Automatic Patch Correctness Assessment with Large Language Model，又名PatchZero: Zero-Shot Automatic Patch Correctness Assessment，Arxiv 2024 [https://arxiv.org/abs/2303.00202](https://arxiv.org/abs/2303.00202)

## 手动补丁修复的正确性调研

FSE 2011的How Do Fixes Become Bugs?这篇文章分享了操作系统的不正确漏洞修复的相关研究结果，即14.8%~24.4%的补丁是不正确的，已经对端侧用户造成影响；在几种典型的漏洞类型中，39%的并发漏洞修复不正确；27%的不正确修复是由那些没有接触过补丁相关代码的开发者编写的。

有关补丁并非开发者本人所写，文中给出的解释是：有时难以确定谁最适合编写fix，即使能够确认，也可能没有时间，或者并不负责该项目了；另外，对于大型项目，开发和维护可能是不同团队。对代码本身如果没有很好的理解，会引发if检查不完善等诸多问题。这篇文章也统计对比了写不正确修复与正确修复的开发者往期对项目的代码贡献。错误修复的开发者往期对项目的文件/函数贡献在10.9%/14.6%，正确修复的开发者贡献在16.6%/20.8%，而那些最适合修复的人选的贡献在63.1%/70.8%。揭示了一种现状：漏洞修复与代码审计工作并不总是由那些最熟悉漏洞的人完成的。进一步地，27.2%的修复者没有对该文件提交过代码修改，51.4%的开发者没有对该函数提交过代码修改，进一步导致了不正确修复。

![alt text](/assets/images/Snipaste_2025-01-14_10-00-02.png)

这篇文章也使用了半自动化的方法来确认不正确补丁，即首先根据25行左右的代码重叠、comments指出了对应commits初筛，然后手工细筛。同样地，这篇文章也认为不正确补丁包括incomplete fixes与introducing new problems两种类型。在进行以下类型的漏洞修复时出错：数据竞争、死锁、缓冲区溢出、内存泄漏、语义漏洞（条件语句频繁出现且修复困难）。

检测不正确修复的通用办法：

1. 理解代码改动带来的影响。通过代码分片的方法确定影响补丁范围。
2. 增量式地应用检查器。如果对整个代码仓库进行检查，会造成大量误报，且开销高。
3. 处理未完全修复问题。处理那些具有相同的根因，在一处修改但是另一处没有修改的问题。

ICSE 2010的Has the bug really been fixed?提出了一种补丁验证方法

MSR 2005的When do changes induces fixes?

### 代码修复中的人力因素

* 周五产生的未完全修复可能会更多
* 大型项目中，确实由一部分漏洞修复是由从未接触过相关代码的人员修复的
* 选择由谁来修复漏洞也是个问题：最后修改代码的？对代码修改最大的？代码的编写者？
* 独立开发组更有可能引入漏洞
* 参与同一binary的开发者越多越容易引发bug

## 数据集

P3: A Dataset of Partial Program Patches 通过半自动化的方法构建了partial-fixes数据集。首先根据Github Issues判断：如果issue在某个commit后被重新打开，或者issue包含多个commits且CI pipeline至少在非最后一个commit上failed，则认为是候选的部分修复。对于Linux Kernel，则通过固定的“Fixes:”关键字来搜索commit comment。最后从1705个候选数据中整理出187个partial fixes，15个no partial fixes，1116个unclassfied/unknown候选，剩下387个候选在爬取结束后失效。大多数部分修复和算术、控制流操作相关，通常是由条件或循环语句的条件判断错误导致的。文章没有明确指出手工检查的标准是什么，因此理解下来手工的目的是排除性能提高等噪声数据，不对最终patch是否真正修复做语义检查。