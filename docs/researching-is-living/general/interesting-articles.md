# 有趣文章

1. [[Usenix Security 2021] Understanding and Detecting Disordered Error Handling with Precise Function Pairing](https://www.usenix.org/conference/usenixsecurity21/presentation/wu-qiushi) 不正确的错误处理函数本身可能也会带来新的错误，尤其是在做一些前期清理工作时，执行顺序不正确会带来提权、崩溃与DoS。本文希望推断出预期的清理函数。
2. [[Usenix Security 2020] Actions Speak Louder than Words: Entity-Sensitive Privacy Policy and Data Flow Analysis with PoliCheck](https://www.usenix.org/conference/usenixsecurity20/presentation/andow) 考虑到数据流向的实体，对应用程序的隐私规范进行研究建模。
3. [[NDSS 2019] https://www.youtube.com/watch?v=dMndb0Xmr4k&t=1s&list=PLfUWWM-POgQs9SPvg-UA-TNG7UVEcdz8l&index=5](https://www.ndss-symposium.org/ndss-paper/how-bad-can-it-git-characterizing-secret-leakage-in-public-github-repositories/) GitHub上由于一些不当操作可能会导致API密钥泄露。本文研究表明这种泄露非常猖獗，并且远没有解决问题。



