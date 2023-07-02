# 情景模板

提出本文工作：

* In this paper, we propose a novel approach to fault localization, SmartFL, that considers the four factors via efficient probabilistic modeling of the program semantics.
* In this work, we propose POMP++, a system to address the above limitations in analyzing a post-crash artifact and pinpointing statements pertaining to the crash.
* In this paper, we present REPT, a practical system that enables reverse debugging of software failures in deployed systems.

凝练本文实验效果：

* We design and implement REPT, deploy it on Microsoft Windows, and integrate it into WinDbg. We evaluate REPT on 16 real-world bugs and show that it can recover data values accurately (92% on average) and efficiently (in less than 20 seconds) for these bugs. We also show that it enables effective reverse debugging for 14 bugs.

提出本文novelty：

* The novelty of this work lies in two aspects. First, we propose a new VSA-based approach for memory alias verification. xxx. Second, we develop new schemes to incorporate our customized VSA to POMP. xxx.

提出本文insight：

* Our core insight is that the probability of a fault in the current program element leads to the current test results can be efficiently estimated by analyzing the following:

准备开始介绍技术细节：

* In this section, we elaborate on the technical details of our xxx approach.  First, we describe how to xxx. Second, we discuss how to xxx. Finally, we discuss how to xxx.
* As we elaborate below, the reasons behind this are two folds.

说目前的工作研究的主要内容受限、别的方法存在问题：

* However, it inevitably detours the fuzzing program away from the critical objects.
* Existing approaches either consider the full semantics of the program (e.g., mutation-based fault localization and angelic debugging), leading to scalability issues, or ignore the semantics of the program (e.g., spectrum-based fault localization), leading to imprecise localization results.
* However, all existing approaches only consider whether a program entity exists in samples but neglect the execution times of the entities in a certain sample and the sequence of their executions. As demonstrated in Section 5, without such sequence information, program spectrum-based fault localization would inevitably introduce imprecision.

一些工作细节：

*  In our work, we manually annotate all these sinks based on their naming patterns.