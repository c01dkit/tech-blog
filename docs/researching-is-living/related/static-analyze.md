# 论文略读

## 静态分析

[USENIX Sec 2021] Detecting Kernel Refcount Bugs with Two-Dimensional Consistency Checking [[PDF]](https://www.usenix.org/conference/usenixsecurity21/presentation/tan)

linux内核中的refcount帮助管理资源引用计数，但存在错误更新的问题，主要包括over decrease和missing decrease，导致提权等漏洞。refcount漏洞挑战在于缺少bug oracle、难以识别refcount字段。本文提出两个核心观察：INC和DEC操作通常伴随pre-conditions，具有严格的互操作关系、同一个对象的INC和DEC函数将常被多次调用，并遵循相同的使用方式，这种使用方式大多情况是bug-free的。整体工作分为三步：通过类型分析与基于行为的推断方法确定refcount字段、收集执行INC操作的函数并执行路径敏感的数据流分析以对其中的INC行为（包括其调用者中的 DEC 行为）进行建模、检查配对的INC和DEC建模行为的一致性。