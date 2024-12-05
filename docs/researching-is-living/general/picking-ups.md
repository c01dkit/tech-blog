# 文句摘录

*Alligator in Vest: A Practical Failure-Diagnosis Framework via Arm Hardware Features (ISSTA 2023)*

* In light of these limitations, we propose Investigator, a practical failure diagnosis framework on Arm to fulfill the three requirements.

*RR: A Fault Model for Efficient TEE Replication (NDSS 2023)*

* The correctness of replication protocols hinges on the property of quorum intersection.
* In quorum-based protocols, this property is enforced by ensuring that any pair of quorums intersects in at least one replica that does not deviate from its prescribed behavior.

*No Grammar, No Problem: Towards Fuzzing the Linux Kernel without System-Call Descriptions (NDSS 2023)*

* However, the process of manually collecting system-call traces, or writing descriptions is prone to human-error: the immediate coverage gains from descriptions and traces risk obscuring parts of the code that the fuzzer can no longer exercise meaningfully.

*FUZZUSB: Hybrid Stateful Fuzzing of USB Gadget Stacks (Oakland 2022)*

* While the prevalence and versatility of USB have made our daily life convenient, it has also attracted attackers seeking to exploit vulnerabilities within the USB ecosystem.

*Registered Report: DATAFLOW Towards a Data-Flow-Guided Fuzzer*

* Unfortunately, these more accurate analyses incur a high run-time penalty, impeding fuzzer throughput.
* Unlike DTA, which strives for accuracy, we take inspiration from popular greybox fuzzers (e.g., AFL) and embrace some imprecision in an effort to reduce overhead and thus maximize fuzzing throughput.

*A Survey on Adversarial Attacks for Malware Analysis*

* Adversarial attacks has now emerged as a serious concern, threatening to dismantle and undermine all the progress made in the machine learning domain.
* The fear of evolving adversarial attack is growing among the cyber security research community and has provoked the everlasting war between adversarial attackers and defenders.

*Survivalism: Systematic Analysis of Windows Malware Living-Off-The-Land (Oakland 2021)*

* Orthogonal to our research is the analysis and deobfuscation of script-based malware.


*A Systematical and longitudinal study of evasive behaviors in windows malware (Computers & Security 2021)*

* Using our framework and taxonomy, we study the evasive behaviors adopted by 45,375 malware samples observed in the wild between 2010 and 201*
* We harvest papers, reports, and blog posts from the security community estimating the influence of the public disclosure of evasive techniques on their adoption in the wild.

*Structural Attack against Graph Based Android Malware Detection (CCS 2021)*

* Graph-based detection methods extract features from graphs and use these features to train classifiers for malware detection. By contrast, structural attacks directly modify the graph features and thus they are more intrinsic and effective.

*Deep Learning for Android Malware Defenses: a Systematic Literature Review (ACM Survey 2021)*

* In front of the increasing difficulties of Android malware detection, it is non-trivial to build a robust and transparent detecting model or system only by traditional machine learning techniques.

*Intriguing Properties of Adversarial ML Attacks in the Problem Space (Oakland 2020)*

*  We shed light on the relationship between feature space and problem space, and we introduce the concept of side-effect features as the byproduct of the inverse feature-mapping problem. This enables
us to define and prove necessary and sufficient conditions for the existence of problem-space attacks.



*P2IM: Scalable and Hardware-independent Firmware Testing via Automatic Peripheral Interface Modeling (USENIX SECURITY 2020)*

* The inapplicability of fuzzers on MCU boils down to the lack of a platform where firmware can execute while taking inputs from fuzzers.
* Although the register access patterns and the type identification method are purely empirical, we find that in practice they work fairly reliably and accurately across a wide range of peripheral devices. We attribute this practical and promising results to two factors.
* The instantiation is on-demand and interleaved with the firmware fuzzing/testing process.

*Toward the Analysis of Embedded Firmware through Automated Re-hosting (RAID 2019)*

* Unfortunately for security researchers, in stark contrast to the desktop and mobile ecosystems, market forces have not created any de facto standard for components, protocols, or software, hampering existing program analysis approaches, and making the understanding of each new device an independent, mostly manual, time-consuming effort.
* In this work, we develop an approach to re-hosting that achieves all of them, and propose a proof-of-concept system, called PRETENDER, which is able to observe hardware-firmware interactions and create models of hardware peripherals automatically.
* To deal with the plethora of software applications that need to be analyzed on desktop and mobile platforms, the security community has developed many techniques for enabling the scalable analysis of programs to find bugs and detect malice.
* Dynamic approaches typically rely on virtualization to enable parallel, scalable analyses, while symbolic approaches rely on function summarization of the underlying operating system to minimize the code
that they need to execute. In order to use any of these tools, the analyst must take the program out of its original execution environment, and provide a suitable analysis environment able to execute it. This is a process referred to as re-hosting.

*REPT: Reverse Debugging of Failures  in Deployed Software (USENIX SECURITY 2018)*

* Moreover, even though root cause diagnosis can help a developer determine the reasons behind a failure, developers often require a deeper understanding of the conditions and the state leading to a failure to fix a bug, which these systems do not provide.

*What You Corrupt Is Not What You Crash: Challenges in Fuzzing Embedded Devices (NDSS 2018)*

* As a result, silent memory corruptions occur more frequently on embedded devices than on traditional computer systems, creating a significant challenge for conducting fuzzing sessions on embedded systems software.

*Postmortem Program Analysis with Hardware-Enhanced Post-Crash Artifacts (USENIX SECURITY 2017)*

* As such, it is tedious and arduous for a software developer to plow through an execution trace to diagnose the root cause of a software failure.
* Given that backward taint analysis mimics how a software developer (or security analyst) typically diagnoses the root cause of a program failure, this observation indicates that POMP has a great potential to reduce manual efforts in failure diagnosis.

*POMP++: Facilitating Postmortem Program Diagnosis with Value-Set Analysis*

* Briefly speaking, postmortem program diagnosis is to identify the program statements pertaining to the crash, analyze these statements, and eventually figure out why a bad value was passed to the crash site.

*A Survey on Software Fault Localization (TSE 2016)*

* Furthermore, manual fault localization relies heavily on the software developer’s experience, judgment, and intuition to identify and prioritize code that is likely to be faulty.