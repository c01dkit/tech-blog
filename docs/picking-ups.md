# 文章学习

## 文句摘录

*No Grammar, No Problem: Towards Fuzzing the Linux Kernel without System-Call Descriptions (NDSS 2023)*

1. However, the process of manually collecting system-call traces, or writing descriptions is prone to human-error: the immediate coverage gains from descriptions and traces risk obscuring parts of the code that the fuzzer can no longer exercise meaningfully.

*FUZZUSB: Hybrid Stateful Fuzzing of USB Gadget Stacks (Oakland 2022)*

1. While the prevalence and versatility of USB have made our daily life convenient, it has also attracted attackers seeking to exploit vulnerabilities within the USB ecosystem.

*Registered Report: DATAFLOW Towards a Data-Flow-Guided Fuzzer*

1. Unfortunately, these more accurate analyses incur a high run-time penalty, impeding fuzzer throughput.
2. Unlike DTA, which strives for accuracy, we take inspiration from popular greybox fuzzers (e.g., AFL) and embrace some imprecision in an effort to reduce overhead and thus maximize fuzzing throughput.

*A Survey on Adversarial Attacks for Malware Analysis*

1. Adversarial attacks has now emerged as a serious concern, threatening to dismantle and undermine all the progress made in the machine learning domain.
2. The fear of evolving adversarial attack is growing among the cyber security research community and has provoked the everlasting war between adversarial attackers and defenders.

*Survivalism: Systematic Analysis of Windows Malware Living-Off-The-Land (Oakland 2021)*

1. Orthogonal to our research is the analysis and deobfuscation of script-based malware.


*A Systematical and longitudinal study of evasive behaviors in windows malware (Computers & Security 2021)*

1. Using our framework and taxonomy, we study the evasive behaviors adopted by 45,375 malware samples observed in the wild between 2010 and 2019.
2. We harvest papers, reports, and blog posts from the security community estimating the influence of the public disclosure of evasive techniques on their adoption in the wild.

*Structural Attack against Graph Based Android Malware Detection (CCS 2021)*

1. Graph-based detection methods extract features from graphs and use these features to train classifiers for malware detection. By contrast, structural attacks directly modify the graph features and thus they are more intrinsic and effective.

*Deep Learning for Android Malware Defenses: a Systematic Literature Review (ACM Survey 2021)*

1. In front of the increasing difficulties of Android malware detection, it is non-trivial to build a robust and transparent detecting model or system only by traditional machine learning techniques.

*Intriguing Properties of Adversarial ML Attacks in the Problem Space (Oakland 2020)*

1.  We shed light on the relationship between feature space and problem space, and we introduce the concept of side-effect features as the byproduct of the inverse feature-mapping problem. This enables
us to define and prove necessary and sufficient conditions for the existence of problem-space attacks.



*P2IM: Scalable and Hardware-independent Firmware Testing via Automatic Peripheral Interface Modeling (USENIX SECURITY 2020)*

1. The inapplicability of fuzzers on MCU boils down to the lack of a platform where firmware can execute while taking inputs from fuzzers.
2. Although the register access patterns and the type identification method are purely empirical, we find that in practice they work fairly reliably and accurately across a wide range of peripheral devices. We attribute this practical and promising results to two factors.
3. The instantiation is on-demand and interleaved with the firmware fuzzing/testing process.

*Toward the Analysis of Embedded Firmware through Automated Re-hosting (RAID 2019)*

1. Unfortunately for security researchers, in stark contrast to the desktop and mobile ecosystems, market forces have not created any de facto standard for components, protocols, or software, hampering existing program analysis approaches, and making the understanding of each new device an independent, mostly manual, time-consuming effort.
2. In this work, we develop an approach to re-hosting that achieves all of them, and propose a proof-of-concept system, called PRETENDER, which is able to observe hardware-firmware interactions and create models of hardware peripherals automatically.
3. To deal with the plethora of software applications that need to be analyzed on desktop and mobile platforms, the security community has developed many techniques for enabling the scalable analysis of programs to find bugs and detect malice.
4. Dynamic approaches typically rely on virtualization to enable parallel, scalable analyses, while symbolic approaches rely on function summarization of the underlying operating system to minimize the code
that they need to execute. In order to use any of these tools, the analyst must take the program out of its original execution environment, and provide a suitable analysis environment able to execute it. This is a process referred to as re-hosting.

*What You Corrupt Is Not What You Crash: Challenges in Fuzzing Embedded Devices (NDSS 2018)*

1. As a result, silent memory corruptions occur more frequently on embedded devices than on traditional computer systems, creating a significant challenge for conducting fuzzing sessions on embedded systems software.

*Postmortem Program Analysis with Hardware-Enhanced Post-Crash Artifacts (USENIX SECURITY 2017)*

1. As such, it is tedious and arduous for a software developer to plow through an execution trace to diagnose the root cause of a software failure.

## 四大调查

1. [[Usenix Security 2022] "I feel invaded, annoyed, anxious and I may protect myself": Individuals' Feelings about Online Tracking and their Protective Behaviour across Gender and Country](https://www.usenix.org/conference/usenixsecurity22/presentation/coopamootoo)
2. [[Usenix Security 2022] "Like Lesbians Walking the Perimeter": Experiences of U.S. LGBTQ+ Folks With Online Security, Safety, and Privacy Advice](https://www.usenix.org/conference/usenixsecurity22/presentation/geeng)
3. [[Usenix Security 2022] How and Why People Use Virtual Private Networks](https://www.usenix.org/conference/usenixsecurity22/presentation/dutkowska-zuk)
4. [[Usenix Security 2021] "It's the Company, the Government, You and I": User Perceptions of Responsibility for Smart Home Privacy and Security](https://www.usenix.org/conference/usenixsecurity21/presentation/haney)
5. [[Usenix Security 2021] "Shhh...be quiet!" Reducing the Unwanted Interruptions of Notification Permission Prompts on Chrome](https://www.usenix.org/conference/usenixsecurity21/presentation/bilogrevic)
6. [[Usenix Security 2021] Effect of Mood, Location, Trust, and Presence of Others on Video-Based Social Authentication](https://www.usenix.org/conference/usenixsecurity21/presentation/guo)
7. [[Usenix Security 2021] 'Passwords Keep Me Safe' – Understanding What Children Think about Passwords](https://www.usenix.org/conference/usenixsecurity21/presentation/theofanos)
8. [[Usenix Security 2021] "It's stressful having all these phones": Investigating Sex Workers' Safety Goals, Risks, and Practices Online](https://www.usenix.org/conference/usenixsecurity21/presentation/mcdonald)
9. [[Usenix Security 2021] "Now I'm a bit angry:" Individuals' Awareness, Perception, and Responses to Data Breaches that Affected Them](https://www.usenix.org/conference/usenixsecurity21/presentation/mayer)
10. [[Usenix Security 2020] "I am uncomfortable sharing what I can't see": Privacy Concerns of the Visually Impaired with Camera Based Assistive Applications](https://www.usenix.org/conference/usenixsecurity20/presentation/akter)
11. [[Usenix Security 2020 | Distingguished Paper Award] Understanding security mistakes developers make: Qualitative analysis from Build It, Break It, Fix It](https://www.usenix.org/conference/usenixsecurity20/presentation/votipka-understanding)
12. [[Usenix Security 2020] An Observational Investigation of Reverse Engineers’ Processes](https://www.usenix.org/conference/usenixsecurity20/presentation/votipka-observational)
13. [[Usenix Security 2020] That Was Then, This Is Now: A Security Evaluation of Password Generation, Storage, and Autofill in Browser-Based Password Managers](https://www.usenix.org/conference/usenixsecurity20/presentation/oesch)
14. [[NDSS 2022] An In-depth Analysis of Duplicated Linux Kernel Bug Reports](https://www.ndss-symposium.org/ndss-paper/auto-draft-246/)
15. [[NDSS 2020] Are You Going to Answer That? Measuring User Responses to Anti-Robocall Application Indicators](https://www.ndss-symposium.org/ndss-paper/are-you-going-to-answer-that-measuring-user-responses-to-anti-robocall-application-indicators/)
16. [[NDSS 2019] Time Does Not Heal All Wounds: A Longitudinal Analysis of Security-Mechanism Support in Mobile Browsers](https://www.ndss-symposium.org/ndss-paper/time-does-not-heal-all-wounds-a-longitudinal-analysis-of-security-mechanism-support-in-mobile-browsers/)
17. [[NDSS 2019] A First Look into the Facebook Advertising Ecosystem](https://www.ndss-symposium.org/ndss-paper/measuring-the-facebook-advertising-ecosystem/)

## 有趣文章

1. [[Usenix Security 2021] Understanding and Detecting Disordered Error Handling with Precise Function Pairing](https://www.usenix.org/conference/usenixsecurity21/presentation/wu-qiushi) 不正确的错误处理函数本身可能也会带来新的错误，尤其是在做一些前期清理工作时，执行顺序不正确会带来提权、崩溃与DoS。本文希望推断出预期的清理函数。
2. [[Usenix Security 2020] Actions Speak Louder than Words: Entity-Sensitive Privacy Policy and Data Flow Analysis with PoliCheck](https://www.usenix.org/conference/usenixsecurity20/presentation/andow) 考虑到数据流向的实体，对应用程序的隐私规范进行研究建模。
3. [[NDSS 2019] https://www.youtube.com/watch?v=dMndb0Xmr4k&t=1s&list=PLfUWWM-POgQs9SPvg-UA-TNG7UVEcdz8l&index=5](https://www.ndss-symposium.org/ndss-paper/how-bad-can-it-git-characterizing-secret-leakage-in-public-github-repositories/) GitHub上由于一些不当操作可能会导致API密钥泄露。本文研究表明这种泄露非常猖獗，并且远没有解决问题。


## 文词学习

* encyclopedic 广博的
* unprecedented 史无前例的，空前的
* bluntly 直言不讳地
* as per some estimates 根据一些估计
* indispensable 必不可少的
* to name just a few 仅举几例
* discriminate 鉴别，区别；有区别的
* remediation 整治
* cumbersome 繁琐的
* drastically 剧烈地
* impede 阻碍
* stochastic 随机的
* sharp-edged plateau
* saturating 饱和的
* avert 避免，纾解
* delineation 划定
* nuisance 滋扰
* menace 威胁，危险的人或物
* dismantle 拆开，拆卸，废除
* undermine 暗中破坏，从根基处损坏
* provoke 激起，引起
* ransomware 勒索软件
* withstand 抵挡，经受住，抵抗
* camouflage 伪装，隐蔽，欺瞒
* influx 大量涌入，汇集
* nullify 使无效，作废，取消
* calibrate 校准
* ameliorate 改善，改良
* prolifical 多产的
* henceforth 从今以后，今后
* surmise 推测
* smuggle 走私
* prudent 谨慎的
* intriguing 有趣的，迷人的
* byproduct 副产品，意外结果
* inconspicuous 不明显的 不引人注目的
* brittle 易碎的，难以相处的，尖刻暴躁的，冷淡的
* deceive 欺骗，误导
* versatility 多才多艺，多用途，易变，可转动性
* inflate 使膨胀，使充气，物价上涨
* conflate 合并，混合
* incentive 动机，刺激，诱因，鼓励
* bounty 赏金，奖金，赠物
* exacerbate 使恶化，使加重
* fluctuation 波动，涨落，起伏
* susceptible 易受影响的，易受感染的，可以接受或允许的
* extraneous 外来的，外部的，无关的
* amenable （对法律等）负责的，易控制的；经得起检验或考查的
* vicinity 附近，临近，附近地区，大约的程度或数量
* retention 保留，记忆力，保持力，滞留，扣留
* suffice 足够，有能力，满足……的需要，使满足
* rudimentary 简陋的
* inadvertently 漫不经心地，疏忽地
* cease 停止，终止
* collectively 全体地，共同地
* daunting 令人畏惧的，使人气馁的
* encompass 围绕，包围，包含，包括
* devastating 毁灭性的，令人震惊的
* retrofit 给机器设备装配（新部件），翻新，改型
* yield to 让步于，使自己受到xxx的支配
* sterilizer 消毒者，消毒器
* salient 显著的，突出的，跳跃的，（角）凸出的
* nuanced 有细微差别的
* discern 察觉出，了解；分辨出
* subsidised 补贴的
* culprit 犯人，罪犯
* holistic 全盘的，整体的，功能整体性的
* endeavor 努力，尽力
* influx 注入，流入，汇集
* plausible 貌似真实的，貌似有理的，花言巧语的
* pertain 有关，存在，适用
* obsolescence 废弃，陈旧过时，（器官）废退
* resort to 诉诸，依靠，求助于
* discrepancy 差异，不一致，区别
* impair 损害，削弱
* hefty 重的，健壮的，异常大的，重量级的
* paucity 少量，缺乏，不足，缺少
* obstruct 阻碍，阻止，妨碍
* retention 保留，记忆力，滞留，扣留
* envision 设想，预想 vt.
* remediate 补救，治疗，矫正，修复
* conundrum 谜语，难解的问题
* depict 展示，描述，显示
* expedite 加快进展
* remedy 治疗法，改正，改进，补救
* instinctive reaction 本能反应
* deem 认为，视为，相信
* detour 绕路，绕道，弯路
* futile 无效的，没用的
* the hassle of sth. 某事带来的麻烦
* unencumbered 没有阻碍的，不受妨碍的，无负担的
* idiosyncrasy （某人特有的）气质，习性，癖好

## 情景

准备开始介绍技术细节：

* In this section, we elaborate on the technical details of our xxx approach.  First, we describe how to xxx. Second, we discuss how to xxx. Finally, we discuss how to xxx.
* As we elaborate below, the reasons behind this are two folds.

说别的方法存在问题：

* However, it inevitably detours the fuzzing program away from the critical objects.

一些工作细节：

*  In our work, we manually annotate all these sinks based on their naming patterns.