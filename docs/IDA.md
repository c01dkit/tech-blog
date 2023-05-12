# IDA使用

## 反编译ARM raw binary

加载时选择Processor type，比如ARM Little-endian [ARM]，随后根据实际加载情况设置ROM的起始地址和Input file地址。

raw binary的前四字节可能是初始sp值，随后四字节可能是初始pc值。按++g++并输入pc值，++alt+g++设置T寄存器值为1（0表示ARM，1表示Thumb），然后选中pc及之后所有代码，按++c++进行MakeCode。