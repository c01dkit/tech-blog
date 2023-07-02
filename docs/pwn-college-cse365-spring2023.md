# CSE 365 - Spring 2023

## Talking Web 学习笔记

请求第一行Request line：请求方法 URI 协议版本 CRLF

响应第一行Status line：协议版本 状态码 解释 CRLF

### 请求方法

* GET：获取信息，如果URI是处理程序，则获取程序运行后的结果（而不是源码）
* HEAD：和GET类似，但是response不返回body，一般用于测试资源是否存在、修改时间，获取资源元数据等
* POST：提交额外的信息用于服务端处理

`HTTP URL Scheme：scheme://host:port/path?query#fragment`

* scheme 访问资源的协议，比如http
* host 持有资源的主机
* port 提供服务的程序使用的端口
* path 确定特定资源
* query 资源可以利用的额外信息
* fragment 客户端有关这一资源的信息（不会传给服务器？）

### urlencoding

请求的资源含有一些特殊符号比如?,/,&,#等等时，使用%xx进行编码，其中xx是ASCII码

POST请求时，需要带上Content-Type

* Content-Type: application/x-www-form-urlencoded
* Content-Type: application/json

前者body里写a=xx，后者写{"a":"xx"}。json可以构造更复杂的blob

RFC 1945 HTTP协议是无状态的，但是网络应用是有状态的。使用cookie来保持状态。

## Talking Web WriteUps



这个章节的题目是用curl、python和nc来实现发送各种http请求，先运行`/challenge/run`启动flask服务器，然后新开个终端用各种姿势连接本地127.0.0.1即可。

这三种工具的大致思路：
* curl是通过一些参数来加设定
* nc需要生写http请求内容
* python可以用requests来做

需要先简单地连接127.0.0.1然后根据报错提示来修改请求。

**Level 1**

Send an HTTP request using curl

```shell
curl http://127.0.0.1

```

**Level 2**

Send an HTTP request using nc

```shell
nc 127.0.0.1 80
GET / HTTP/1.1


```

**Level 3**

Send an HTTP request using python

```python
import requests as r
r.get("http://127.0.0.1").text
```

**Level 4**

Set the host header in an HTTP request using curl

```shell
curl -H 'host:xxxxx' http://127.0.0.1
```

**Level 5**

Set the host header in an HTTP request using nc

```shell
nc 127.0.0.1 80
GET / HTTP/1.1
host:xxxxx


```

**Level 6**

Set the host header in an HTTP request using python

```python
import requests as r
r.get("http://127.0.0.1", headers={"host":"xxx"}).text
```


**Level 7**

Set the path in an HTTP request using curl

```shell
curl http://127.0.0.1/xxxxx
```

**Level 8**

Set the path in an HTTP request using nc

```shell
nc 127.0.0.1 80
GET /xxxx HTTP/1.1


```

**Level 9**

Set the path in an HTTP request using python


```python
import requests as r
r.get("http://127.0.0.1/xxx").text

```

**Level 10~12**

URL encode a path in an HTTP request using curl/nc/python

用%20替换掉空格即可

**Level 13~15**

Specify an argument in an HTTP request using curl/nc/python

GET加参数，在路径后面追加?a=xxx即可

nc时加到nc连接以后的GET后面

**Level 16~18**

Specify multiple arguments in an HTTP request using curl/nc/python

结合10~15题，空格用%20换掉，与号用%26换掉，井号用%23换掉

**Level 19~21**

Include form data in an HTTP request using curl/nc/python

```shell
#curl
curl http://127.0.0.1 -F a=xxx

#nc
POST / HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Content-Length:34

a=xxx

#python
import requests as r
r.post("http://127.0.0.1",data={'a':'xxx'}).text
```

**Level 22~24**

Include form data with multiple fields in an HTTP request using curl/nc/python

```shell
#curl
curl http://127.0.0.1 -F a=xxx -F b='xxxx'

#nc
POST / HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Content-Length: 78

a=xxx&b=xxx

#python
import requests as r
r.post("http://127.0.0.1",data={'a':'xxx','b':'xxx'}).text

```

**Level 25~27**

Include json data in an HTTP request using curl/nc/python

```shell
#curl
curl -X POST -H 'Content-Type:application/json' -d '{"a":"xxx"}' http://127.0.0.1

#nc
echo -ne 'POST / HTTP/1.1\r\nContent-Type: application/json\r\nContent-Length:40\r\n\r\n{"a":"xxx"}' |  nc 127.0.0.1 80

#python
import requests as r
import json
r.post("http://127.0.0.1",headers={"Content-Type":"application/json"},data=json.dumps({"a":"xxx"})).text
```

**Level 28~30**

Include complex json data in an HTTP request using curl/nc/python

```shell
#curl
curl -X POST -H 'Content-Type: application/json' -H 'Content-Length: 121' -d '{"a":"xxx", "b":{"c": "xxxx", "d": ["xxx", "xxx"]}}' http://127.0.0.1

#nc
echo -ne 'POST / HTTP/1.1\r\nContent-Type: application/json\r\nContent-Length: 121\r\n\r\n{"a":"xxx", "b":{"c": "xxx", "d": ["xxx", "xxx"]}}' | nc 127.0.0.1 80

#python
import requests as r
import json
r.post("http://127.0.0.1",headers={"Content-Type":"application/json"},data=json.dumps({"a":"xxx","b":{'c': 'xxx', 'd': ['xxx', 'xxx']}})).text
```

**Level 31~33**

Follow an HTTP redirect from HTTP response using curl/nc/python

```shell
#curl
curl -L http://127.0.0.1

#nc
echo -ne "GET /xxx HTTP/1.1\r\n\r\n" | nc 127.0.0.1 80

#python
#python默认跟随跳转
import requests as r
r.get("http://127.0.0.1").text
```

**Level 34~36**

Include a cookie from HTTP response using curl/nc/python

```shell
#curl
curl http://127.0.0.1 -v
curl -b "cookie=xxx" http://127.0.0.1

#nc
echo -ne "GET / HTTP/1.1\r\n\r\n" | nc 127.0.0.1 80
echo -ne "GET / HTTP/1.1\r\nCookie:cookie=xxxx\r\n\r\n" | nc 127.0.0.1 80

#python 默认自动接受cookie
import requests as r
r.get("http://127.0.0.1").text
```

**Level 37~39**

Make multiple requests in response to stateful HTTP responses using curl/nc/python

```shell
#curl 完成3次交互即可
curl -b "session=xxx" http://127.0.0.1 -v 
curl -b "session=xxx" http://127.0.0.1 -v 
curl -b "session=xxx" http://127.0.0.1 -v 

#nc
echo -ne "GET / HTTP/1.1\r\nCookie:session=xxx\r\n\r\n" | nc 127.0.0.1 80
echo -ne "GET / HTTP/1.1\r\nCookie:session=xxx\r\n\r\n" | nc 127.0.0.1 80
echo -ne "GET / HTTP/1.1\r\nCookie:session=xxx\r\n\r\n" | nc 127.0.0.1 80

#python
import requests as r
r.get("http://127.0.0.1").text
```

## Assembly Crash Course学习笔记

## Assembly Crash Course Writeups

这个章节的题需要把汇编变成raw bytes，然后喂给/challenge/run。需要先运行这个run，然后根据要求完成。比如可以用pwntools的asm模块生成汇编，然后echo进run里。

**Level 1**

In this level you will work with registers_use! Please set the following: rdi = 0x1337

```python
from pwn import *
context.arch='amd64'
asm('mov rdi,0x1337')

#b'H\xc7\xc77\x13\x00\x00'

```
然后在shell里`echo -ne 'H\xc7\xc77\x13\x00\x00' | /challenge/run`即可。

**Level 2**

```python
asm('add rdi,0x331337')
```

**Level 3**

```python
asm('imul rdi,rsi; add rdi,rdx; mov rax,rdi')
```

**Level 4**

学习div除法，`div reg`会使用rax作为被除数，reg作为除数，然后自动使用rax存放商，rdx存放余数。

```python
asm('mov rax, rdi;div rsi')
```

**Level 5**

```python
asm('mov rax, rdi;div rsi;mov rax, rdx')
```

**Level 6**

除数为2的幂次时，直接使用mov保留寄存器的一部分即可。注意mov两个寄存器长度要一致。

```python
asm('mov al, dil;mov bx, si')
```

**Level 7**

shl左移，shr右移（高位补0）

```python
asm('shl rdi, 59; shr rdi, 63; mov rax, rdi')
```

**Level 8**

`and reg1, reg2`会把reg1和reg2进行逻辑与的结果保存在reg1里。题目不让用mov，那可以采用置0减1的方式获得2^65-1，然后and即可。

```python
asm('xor rax, rax; sub rax, 1; and rax, rdi; and rax, rsi')
```

**Level 9**

题目要求只用and，or，xor实现一个奇偶判断的功能。整体思路是xor反转比特、清空值，or做加法，and取最低位。


```python
asm('xor rax, rax; or rax, 1; and rax, rdi; xor rax, 1')
```

**Level 10**

有关访问内存的操作。`mov reg, [address]`用于把address地址处的值赋给reg，当然也可以`mov [address], reg`把reg的值保存在address地址。加一层方括号只是表示当作地址。不要下意识进行更多次数的解引用。

```python
asm('mov rbx, [0x404000]; mov rax, rbx; add rbx, 0x1337; mov [0x404000], rbx')
```

**Level 11**

如果mov一方为寄存器，一方为地址，会根据寄存器的大小自动推断从地址中load多少字节。

```python
asm('mov al, [0x404000]; mov bx, [0x404000]; mov ecx, [0x404000]; mov rdx, [0x404000];')
```

**Level 12**

对于比较大的立即数，可以先放在寄存器，然后再mov到指定位置。

```python
asm('mov rax, 0xdeadbeef00001337; mov [rdi], rax; mov rax, 0xc0ffee0000; mov [rsi], rax')
```

**Level 13**

```python
asm('mov rax, [rdi]; add rax, [rdi+8]; mov [rsi], rax')
```

**Level 14**

```python
asm('pop rax;sub rax,rdi; push rax')
```

**Level 15**

使用栈可以简单地交换寄存器

```python
asm('push rdi; push rsi; pop rdi; pop rsi')
```

**Level 16**

实现栈上的数据取平均，用[rsp+X]来取值（一般用rbp来取吧？）

```python
asm('mov rax, [rsp]; add rax, [rsp+8]; add rax, [rsp+16]; add rax, [rsp+24]; mov rbx, 4; div rbx; push rax')
```

**Level 17**

使用label设置相对跳转地址，使用单字节的nop填充。不过题目要求的“从jmp偏移0x51的地址”有点迷惑，看结果的话似乎默认是jmp执行后的地址再偏移0x51，而不是jmp指令本身的地址偏移0x51，所以不需要知道jmp指令本身的长度。

```python
asm('jmp lab;'+'nop;'*0x51+'lab: mov rdi, [rsp]; mov rax, 0x403000; jmp rax')
```

**Level 18**

实现if-else跳转。注意内存计算使用dword的32位数据，用eax而不是rax。

```python
from pwn import *
context.arch='amd64'
payload="""mov eax, [rdi+4]
mov ebx, 0x7f454c46
cmp ebx, [rdi]
je case1
mov ebx, 0x5a4d
cmp ebx, [rdi]
je case2
imul eax, [rdi+8]
imul eax, [rdi+12]
jmp done
case1:
    add eax, [rdi+8]
    add eax, [rdi+12]
    jmp done
case2:
    sub eax, [rdi+8]
    sub eax, [rdi+12]
    jmp done
done:
    nop
"""

print(asm(payload))
```

**Level 19**

`jmp [reg + offset]`间接跳转，使用rsi保存跳转表的基地址，用于实现switch。这里好像是jnz不支持间接跳转。

```python
asm('mov rax, rdi; shr rax, 2; jnz final; jmp [rsi + rdi * 8]; final: jmp [rsi + 32]')
```

**Level 20**

实现一个简单的求平均函数

```python
from pwn import *
context.arch='amd64'
payload="""xor rax, rax
xor rcx, rcx
loop:
    cmp rcx, rsi
    je done
    add rax, [rdi + 8 * rcx]
    add rcx, 1
    jmp loop
done:
    div rsi
"""

print(asm(payload))
```

**Level 21**

实现一个strlen函数，逐byte检查是否为0。注意mov不会改变EFLAGS。

```python
from pwn import *
context.arch='amd64'
payload = """
xor rax, rax
test rdi, rdi
jz done
loop: mov bl, [rdi + rax]
test bl,bl
jz done
add rax, 1
jmp loop
done:
    nop
"""

print(asm(payload))
```

**Level 22**

这道题给的解释不是很清楚，尽管是第一次提到使用call进行函数调用，但是没有说64位程序依次使用`rdi,rsi,rdx,rcd,r8,r9`进行传参、`rax`保存函数返回结果，也没有说是由主调函数还是被调函数来保存寄存器。更奇怪的是虽然让实现一个str_lower函数，但是没有按函数实现的标准写PROG，甚至最后还用ret来结束。


```python
from pwn import *
context.arch='amd64'
payload = """
mov rdx, rdi
xor rax, rax
xor rcx, rcx
test rdx, rdx
jz done
loop:
    mov bl, [rdx]
    test bl,bl
    jz done
    cmp bl, 0x5a
    jg notif
    mov rax, 0x403000
    xor rdi, rdi
    mov dil, bl
    call rax
    mov [rdx], al
    add rcx, 1
notif:
    add rdx, 1
    jmp loop
done:
    mov rax, rcx
    ret
"""

print(asm(payload))
```

**Level 23**

实现一个查询字符串中哪个字符最多的函数。每个字符不超过0xffff个，所以要用4字节的寄存器来进行存放。这里似乎不支持直接`mov rbx, [ebp - rcx * 4]`之类的方法，就用r8和r9临时存放一下了。

```python
from pwn import *

context.arch = 'amd64'

payload = """
push rbp
mov rbp, rsp
sub rsp, 0x400
xor rax, rax
xor rcx, rcx
mov rdx, rsi
sub rdx, 0x1
loop1: 
    cmp rcx, rdx
    jg loop1_end
    mov al, [rdi + rcx]
    mov r8, rbp
    mov r9, rax
    imul r9, 4
    sub r8, r9
    mov ebx, [r8]
    add ebx, 1
    mov [r8], ebx
    add rcx, 1
    jmp loop1
loop1_end:
xor rax, rax
xor rbx, rbx
xor rcx, rcx
loop2:
    cmp rcx, 0xff
    jg loop2_end
    mov r8, rbp
    mov r9, rcx
    imul r9, 4
    sub r8, r9
    mov edx, [r8]
    cmp edx, ebx
    jle loop2_conti
    mov rbx, rdx
    mov rax, rcx
loop2_conti:
    add rcx, 1
    jmp loop2
loop2_end:
mov rsp, rbp
pop rbp
ret
"""

print(asm(payload))
```

## Reverse Engineering 学习笔记

## Reverse Engineering Writeups

**Level 1**

* `start`在main函数打断点并运行
* `starti`在_start函数打断点并运行
* `run`不打断点，直接运行
* `attach <PID>`将gdb附着到一个正在运行的进程
* `core <PATH>`分析一个程序运行后产生的coredump文件
* `start <ARG1> <ARG2> < <STDIN_PATH>`运行带有参数的程序，和shell里输命令一样

运行/challenge下的文件，会自动打开gdb，输入`run`启动程序，进入第一关。第一关主要是讲下大致的题目要求，在这里按++c++继续运行会直接给出flag。

**Level 2**

* `info registers`可以查看寄存器的值（或者简单的`i r`）
* `print`用来打印变量或者寄存器的值，比如`p/x $rdi`以16进制打印rdi寄存器的值

本关run以后`p/x $r12`然后按++c++，把结果输入就行。

**Level 3**

* `x/<n><u><f> <address>`用来打印变量或绝对地址的内容。`n`表示number，也就是说要打印几个单元；`u`表示unit size，每个单元的字节长度，可取`b/h/w/g`，分别表示1，2，4，8字节；`f`表示输出格式，可取`d/x/s/i`，分别表示十进制、十六进制、字符串、汇编指令。address表示要打印的地址，可以写成数学表达式。
* `set disassembly-flavor intel`用来修改汇编指令的表示形式，这里是intel指令。

这一关主要是熟悉打印内存数据，可以在++c++进入程序前后用`x/20gx $rsp`对比一下栈上什么数据改变了。算是不看汇编的一点小trick。

**Level 4**

* 使用`stepi <n>`步入n条汇编指令，`nexti <n>`步过n条汇编指令；分别简写为`si`与`ni`
* 使用`finish`执行到当前函数结束并返回
* 使用`break *<addres>`在address处打断点，可以简写为`b *<address>`
* 使用`display/<n><u><f>`来在每一条操作结束后显示某些数值。nuf的用法和`x`打印内存地址一样

trick：使用`disas $pc`查看发现有个win函数，参数用的0。直接`set $rax=0`，`set $pc=xxx`跳转到win的函数就行了。

**Level 5**

* 有关脚本编写，可以预先用gdb语法写好脚本文件xxx.gdb，然后启动gdb的时候加上参数`-x xxx.gdb`，就可以在gdb启动后自动化运行脚本
* `~/.gdbinit`在初始化gdb会话时自动运行

以下是个gdb脚本的例子，`silent`用于在遇到断电时减少输出信息，以及使用`set`和`printf`设置变量、打印值。
```shell
start
break *main+42
commands
silent
set $local_variable = *(unsigned long long*)($rbp-0x32)
printf "Current value: %llx\n", $local_variable
continue
end
continue
```