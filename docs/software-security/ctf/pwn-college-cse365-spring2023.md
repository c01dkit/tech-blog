# CSE 365 - Spring 2023

在终端连接pwn-college时，先在网页端配置下公钥，然后`ssh -i 私钥 hacker@dojo.pwn.college`即可。网页端启动一个实例后，远程也会自动启动对应的环境。问题一般放在根目录的challenge文件夹下

## Talking Web 学习笔记

请求第一行Request line：请求方法 URI 协议版本 CRLF

响应第一行Status line：协议版本 状态码 解释 CRLF

常见的请求方法：

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

请求的资源含有一些特殊符号比如?,/,&,#等等时，使用%xx进行编码，其中xx是ASCII码。这种做法称为urlencoding

POST请求时，需要带上Content-Type

* Content-Type: application/x-www-form-urlencoded
* Content-Type: application/json

前者body里写a=xx，后者写{"a":"xx"}。json可以构造更复杂的blob

RFC 1945 HTTP协议是无状态的，但是网络应用是有状态的。使用cookie来保持状态。

## Assembly Crash Course 学习笔记

## Building a Web Server 学习笔记

使用socket创建一个A-B的网络文件，然后使用bind将socket与具体的ip绑定。使用listen来被动侦听sockfd。使用accept接受外部连接。

使用TCP/IP进行网络通讯，服务器端的例子如：

```c
// int socket(int domain, int type, int protocol)
socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP)

// int bind(int sockfd, struct sockaddr* addr, socklen_t addrlen)
/*
 * struct sockaddr {
 *   uint16_t sa_family;
 *   uint8_t  sa_data[14];   
 * }
 * 
 * struct sockaddr_in {
 *   uint16_t sin_family;
 *   uint16_t sin_port;
 *   uint32_t sin_addr;
 *   uint8_t  __pad[8];
 * }
*/
bind(socket_fd, {sa_family=AF_INET, sin_port=htons(port), sin_addr=inet_addr("0.0.0.0")}, 16)

// int listen(int sock fd, int backlog);
listen(socket_fd, 0)

// int accept(int sockfd, struct sockaddr* addr, socklen_t* addrlen);
tunnel = accept(socket_fd, NULL, NULL)

// revceive http request: GET / HTTP/1.0
read(tunnel, "GET / HTTP/1.0",19)

// response
write(tunnel, "HTTP/1.0 200 OK\r\n\r\n", 19)

// receive http request: GET /flag HTTP/1.0
read(tunnel, "GET /flag HTTP/1.0\r\n\r\n",256)

// open and read file
filefd = open("/flag",O_RDDONLY)
read(filefd, "FLAG", 256)

//response
write(tunnel, "HTTP/1.0 200 OK\r\n\r\nFLAG", 27)

close(tunnel)

```

## Reverse Engineering 学习笔记

* `start`在main函数打断点并运行
* `starti`在_start函数打断点并运行
* `run`不打断点，直接运行
* `attach <PID>`将gdb附着到一个正在运行的进程
* `core <PATH>`分析一个程序运行后产生的coredump文件
* `start <ARG1> <ARG2> < <STDIN_PATH>`运行带有参数的程序，和shell里输命令一样
* `info registers`可以查看寄存器的值（或者简单的`i r`）
* `print`用来打印变量或者寄存器的值，比如`p/x $rdi`以16进制打印rdi寄存器的值
* `x/<n><u><f> <address>`用来打印变量或绝对地址的内容。`n`表示number，也就是说要打印几个单元；`u`表示unit size，每个单元的字节长度，可取`b/h/w/g`，分别表示1，2，4，8字节；`f`表示输出格式，可取`d/x/s/i`，分别表示十进制、十六进制、字符串、汇编指令。address表示要打印的地址，可以写成数学表达式。
* `set disassembly-flavor intel`用来修改汇编指令的表示形式，这里是intel指令。
* 使用`stepi <n>`步入n条汇编指令，`nexti <n>`步过n条汇编指令；分别简写为`si`与`ni`
* 使用`finish`执行到当前函数结束并返回
* 使用`break *<addres>`在address处打断点，可以简写为`b *<address>`
* 使用`display/<n><u><f>`来在每一条操作结束后显示某些数值。nuf的用法和`x`打印内存地址一样
* 有关脚本编写，可以预先用gdb语法写好脚本文件xxx.gdb，然后启动gdb的时候加上参数`-x xxx.gdb`，就可以在gdb启动后自动化运行脚本
* `~/.gdbinit`在初始化gdb会话时自动运行
* 使用`call`直接调用函数，比如`call (void)win()`
* 使用`set pagination off`关闭分页确认
以下是个gdb脚本的例子，`silent`用于在遇到断点时减少输出信息，以及使用`set`和`printf`设置变量、打印值。

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

* 使用`if`、`catch`来劫持systemcall，比如：

```shell
start
catch syscall read
commands
    silent
    if ($rdi == 42)
        set $rdi = 0
    end
    continue
end
continue
```




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
## Building a Web Server Writeups

不得不吐槽pwn-college有一点不好，每个模块第一个challenge说明太少了，完全不知道从哪开始下手。在challenge 1的wp里详细讲一下这个模块怎么开始做，然后后续就省略了。

用汇编写server，可以查表[64位syscall手册](https://x64.syscall.sh/)

**Level 1**

首先还是运行/challeng/run，得到一段输出：

```text
===== Welcome to Building a Web Server! =====
In this series of challenges, you will be writing assembly to interact with your environment, and ultimately build a web server
In this challenge you will exit a program.

Usage: `/challenge/run <path_to_web_server>`

$ cat server.s
.intel_syntax noprefix
.globl _start

.section .text

_start:
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

$ as -o server.o server.s && ld -o server server.o

$ strace ./server
execve("./server", ["./server"], 0x7ffccb8c6480 /* 17 vars */) = 0
exit(0)                                 = ?
+++ exited with 0 +++
```

这道题的意思是让用汇编写一个服务端。在运行`/challenge/run server`的时候，判题程序会启动用户指定的这个server，然后检查这个server程序是不是直接exit(0)了。所以只需要编译一个exit(0)的server即可。

题目里其实已经给出了server.s的模板（cat server.s的输出）和编译方式（as -o server.o server.s && ld -o server server.o）。所以这道题只需要把`cat server.s`的输出保存到server.s文件，然后直接运行`as -o server.o server.s && ld -o server server.o`编译出一个server的可执行程序，最后运行`/challenge/run ./server`即可。

模板里只执行了一个退出的syscall，正好是这一题的要求。本来以为这道题意思是自己写一个server的汇编文件，然后run的时候指定源文件，由判题程序编译的呢，结果发现run的时候是需要指定一个编译好的可执行程序hh。

完整解题步骤如下：

```text
hacker@building-a-web-server-level-1:~$ echo ".intel_syntax noprefix
.globl _start

.section .text

_start:
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data" > ./server.s

hacker@building-a-web-server-level-1:~$ as -o server.o server.s && ld -o server server.o

hacker@building-a-web-server-level-1:~$ /challenge/run ./server
===== Welcome to Building a Web Server! =====
In this series of challenges, you will be writing assembly to interact with your environment, and ultimately build a web server
In this challenge you will exit a program.


===== Expected: Parent Process =====
[ ] execve(<execve_args>) = 0
[ ] exit(0) = ?

===== Trace: Parent Process =====
[✓] execve("/proc/self/fd/3", ["/proc/self/fd/3"], 0x7f07cf7959a0 /* 0 vars */) = 0
[✓] exit(0)                                 = ?
[?] +++ exited with 0 +++

===== Result =====
[✓] Success

pwn.college{xxxx}
```

以下的各个题目就只写server.s的内容了

**Level 2**

In this challenge you will create a socket.

```assembly
.intel_syntax noprefix
.globl _start

.section .text

_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall

    push rax
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data
```

**Level 3**

In this challenge you will bind an address to a socket.

在Level2创建socket的基础上，将其绑定到0.0.0.0:80上。（可以运行Level1创建的server来先阅读下题目要求，如下所示）

```
===== Expected: Parent Process =====
[ ] execve(<execve_args>) = 0
[ ] socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
[ ] bind(3, {sa_family=AF_INET, sin_port=htons(<bind_port>), sin_addr=inet_addr("<bind_address>")}, 16) = 0
    - Bind to port 80
    - Bind to address 0.0.0.0
[ ] exit(0) = ?
```

最终解如下。这里直接用栈来保存sockaddr_in结构体了，比较粗暴。

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    push rax

    # bind the socket to 0.0.0.0:80
    mov rdi, rax # socket_fd
    push 0x50000002 # AF_INET(2) and PORT(80) in big endian
    mov rsi, rsp # sockaddr_in
    push 0x0 # IP(0.0.0.0)
    push 0x0 # padding
    push 0x0 # padding
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall


.section .data
```

**Level 4**

In this challenge you will listen on a socket.

使用listen监听这个socket。由于这里listen也要用到之前socket创建的文件描述符，注意到样例的汇编文件最后提示用data了，所以干脆换用数据区来保存各种结构体，也弃用Level3里对栈做的那些修改了。这里sockfd和sockaddr都是地址，所以mov的时候会自动解引用，用lea指令来获得地址本身。

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall
    
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall


.section .data

sockfd:   .quad 0
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding

```

**Level 5**

In this challenge you will accept a connection.

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall
    
    # accept(3, NULL, NULL)
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall


.section .data

sockfd:   .quad 0
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding
```

**Level 6**

In this challenge you will respond to an http request.

这个题的意思是希望实现一个静态的站点，接收客户端发送的请求后，始终回复HTTP/1.0 200 OK。需要创建一个缓冲区保存请求，这里开了个256字节的内存（实际上有140字节）。

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall
    
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 256
    mov rax, 0
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1
    syscall

    # close(4)
    mov rdi, tunnel
    mov rax, 3
    syscall
    
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall


.section .data

sockfd:   .quad 0
tunnel:   .quad 0
request:  .space 256
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding
```

**Level 7**

In this challenge you will respond to a GET request for the contents of a specified file.

实现一个动态一点的服务器。这题中，客户端会请求服务器端读取一个文件并返回结果。文件是判题程序随机生成在/tmp下的，内容长度也是随机的。所以写代码的时候要多预留点缓冲区来保存文件内容。

open文件时，文件名要从request请求里提取。因为生成的文件名长度是固定的，所以懒省事直接在request缓冲区里改了（字符串末尾\0）。

```
===== Expected: Parent Process =====
[ ] execve(<execve_args>) = 0
[ ] socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
[ ] bind(3, {sa_family=AF_INET, sin_port=htons(<bind_port>), sin_addr=inet_addr("<bind_address>")}, 16) = 0
    - Bind to port 80
    - Bind to address 0.0.0.0
[ ] listen(3, 0) = 0
[ ] accept(3, NULL, NULL) = 4
[ ] read(4, <read_request>, <read_request_count>) = <read_request_result>
[ ] open("<open_path>", O_RDONLY) = 5
[ ] read(5, <read_file>, <read_file_count>) = <read_file_result>
[ ] close(5) = 0
[ ] write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
[ ] write(4, <write_file>, <write_file_count>) = <write_file_result>
[ ] close(4) = 0
[ ] exit(0) = ?

===== Trace: Parent Process =====
[✓] execve("/proc/self/fd/3", ["/proc/self/fd/3"], 0x7ffacc256990 /* 0 vars */) = 0
[✓] socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
[✓] bind(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
[✓] listen(3, 0)                            = 0
[✓] accept(3, NULL, NULL)                   = 4
[✓] read(4, "GET /tmp/tmpungh1ajd HTTP/1.1\r\nHost: localhost\r\nUser-Agent: python-requests/2.31.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n", 256) = 155
[✓] open("/tmp/tmpungh1ajd", O_RDONLY)      = 5
[✓] read(5, "3Hy3xnjNjQIBfP6QDUW4ekuQtBwdXQPbhtPFxawXzQ6LXVQDgs8ZlslYncY9DMQohXFVHFyMPnOI6kaGqURTh2fXHuKe2oqjntry7Pt5QQP0148CyzGKtmOigovhOHobD2zujqgJIRXxjny3UVL9", 1024) = 148
[✓] close(5)                                = 0
[✓] write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
[✓] write(4, "3Hy3xnjNjQIBfP6QDUW4ekuQtBwdXQPbhtPFxawXzQ6LXVQDgs8ZlslYncY9DMQohXFVHFyMPnOI6kaGqURTh2fXHuKe2oqjntry7Pt5QQP0148CyzGKtmOigovhOHobD2zujqgJIRXxjny3UVL9", 148) = 148
[✓] close(4)                                = 0
[✓] exit(0)                                 = ?
[?] +++ exited with 0 +++

===== Result =====
[✓] Success
```

使用的汇编代码如下：

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall
    
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 256
    mov rax, 0 # sys_read
    syscall

    # open("<open_path>", O_RDONLY) = 5
    lea rdi, [request+4] # extract file name
    movb [rdi+16], 0
    mov rsi, 0 # O_RDONLY
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax

    # read(5, <read_file>, <read_file_count>) = <read_file_result>
    mov rdi, txtfile
    lea rsi, filecontent
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov filecnt, rax # 

    # close(5)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

    # write(4, <write_file>, <write_file_count>) = <write_file_result>
    mov rdi, tunnel
    lea rsi, filecontent
    mov rdx, filecnt
    mov rax, 1 # sys_write
    syscall

    # close(4)
    mov rdi, tunnel
    mov rax, 3 # sys_close
    syscall

    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

sockfd:   .quad 0
tunnel:   .quad 0
txtfile:  .quad 0
filecnt:  .quad 0
request:  .space 256
filecontent: .space 1024
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding

```

**Level 8**

In this challenge you will accept multiple requests.

使用一个程序接受多个请求。由于socket没有关，在最后加一个accept即可。程序最后accept超时sigkill退出。


```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall
    
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 256
    mov rax, 0 # sys_read
    syscall

    # open("<open_path>", O_RDONLY) = 5
    lea rdi, [request+4] # extract file name
    movb [rdi+16], 0
    mov rsi, 0 # O_RDONLY
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax

    # read(5, <read_file>, <read_file_count>) = <read_file_result>
    mov rdi, txtfile
    lea rsi, filecontent
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov filecnt, rax # 

    # close(5)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

    # write(4, <write_file>, <write_file_count>) = <write_file_result>
    mov rdi, tunnel
    lea rsi, filecontent
    mov rdx, filecnt
    mov rax, 1 # sys_write
    syscall

    # close(4)
    mov rdi, tunnel
    mov rax, 3 # sys_close
    syscall

    # accept(3, NULL, NULL)
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax
    
    # exit
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

sockfd:   .quad 0
tunnel:   .quad 0
txtfile:  .quad 0
filecnt:  .quad 0
request:  .space 256
filecontent: .space 1024
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding
```

**Level 9**

In this challenge you will concurrently accept multiple requests.

这道题是让做一个多进程，父进程负责循环accept，子进程用于动态处理文件读写。根据fork返回值来判断父进程（返回值为子进程pid）还是子进程（返回值为0）。父进程中，关闭tunnel；子进程中，关闭sockfd。

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall

parent_process_1:
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # fork() = <fork_result>
    mov rax, 57 # sys_fork
    syscall
    
    test rax, rax
    jnz parent_process_2
    jz child_process

parent_process_2:

    # close(3)
    mov rdi, tunnel
    mov rax, 3 # sys_close
    syscall
    jmp parent_process_1

child_process:

    # close(3)
    mov rdi, sockfd
    mov rax, 3 # sys_close
    syscall

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 256
    mov rax, 0 # sys_read
    syscall

    # open("<open_path>", O_RDONLY) = 3
    lea rdi, [request+4] # extract file name
    movb [rdi+16], 0
    mov rsi, 0 # O_RDONLY
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax

    # read(3, <read_file>, <read_file_count>) = <read_file_result>
    mov rdi, txtfile
    lea rsi, filecontent
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov filecnt, rax # 

    # close(3)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

    # write(4, <write_file>, <write_file_count>) = <write_file_result>
    mov rdi, tunnel
    lea rsi, filecontent
    mov rdx, filecnt
    mov rax, 1 # sys_write
    syscall

    # exit
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

sockfd:   .quad 0
tunnel:   .quad 0
txtfile:  .quad 0
filecnt:  .quad 0
request:  .space 256
filecontent: .space 1024
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding

```

**Level 10**

In this challenge you will respond to a POST request with a specified file and update its contents.

这道题是用POST请求，要求用多进程处理，在子进程中把POST的请求体保存在临时文件，并返回200 OK。考虑到文件名是定长的，所以沿用之前的方法得到文件名。这里用的一个trick是用"\r\n\r\n"来从请求中分割请求体，并且内容的计算是用read的返回值减去偏移量算的。这是偷懒没有实现解析Content-Length的功能hhh

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall

parent_process_1:
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # fork() = <fork_result>
    mov rax, 57 # sys_fork
    syscall
    
    test rax, rax
    jnz parent_process_2
    jz child_process

parent_process_2:

    # close(3)
    mov rdi, tunnel
    mov rax, 3 # sys_close
    syscall
    jmp parent_process_1

child_process:

    # close(3)
    mov rdi, sockfd
    mov rax, 3 # sys_close
    syscall

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov requestlen, rax

    # open("<open_path>", O_WRONLY|O_CREAT, 0777) = 3
    lea rdi, [request+5] # extract file name
    movb [rdi+16], 0
    mov rsi, 0x41 # O_WRONLY | O_CREAT
    mov rdx, 0777
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax
    
    # locate POST body
    mov rcx, 0
    mov ebx, separate
locate_body:
    mov eax, [request+rcx]
    add rcx, 1
    cmp eax, ebx
    jne locate_body
    # extrace POST body
    add rcx, 3
    mov rdi, txtfile
    lea rsi, [request+rcx]
    mov rdx, requestlen
    sub rdx, rcx
    mov rax, 1 # sys_write
    syscall

    # close(3)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

    # exit
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

sockfd:   .quad 0
tunnel:   .quad 0
txtfile:  .quad 0
filecnt:  .quad 0
requestlen: .quad 0
request:  .space 1024
filecontent: .space 1024
separate: .ascii "\r\n\r\n"
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding
```

**Level 11**

In this challenge you will respond to multiple concurrent GET and POST requests.

直接发了一堆GET和POST混合请求。不过好像没说每个请求要干嘛，就直接结合下level9和level10的结果，比较request是以POST开头还是GET开头，分别跳转到对应的逻辑就行了。

```asm
.intel_syntax noprefix
.globl _start

.section .text
    
_start:
    # create a socket
    mov rdi, 2 # AF_INET
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0 # IPPROTO_IP
    mov rax, 41 # sys_socket
    syscall
    mov sockfd, rax

    # bind the socket to 0.0.0.0:80
    mov rdi, sockfd   # socket_fd
    lea rsi, sockaddr # sockaddr
    mov rdx, 16 # addrlen
    mov rax, 49 # sys_bind
    syscall
    
    # listen(3, 0)
    mov rdi, sockfd
    mov rsi, 0
    mov rax, 50 # sys_listen
    syscall

parent_process_1:
    # accept(3, NULL, NULL) = 4
    mov rdi, sockfd
    mov rsi, 0
    mov rdx, 0
    mov rax, 43 # sys_accept
    syscall
    mov tunnel, rax

    # fork() = <fork_result>
    mov rax, 57 # sys_fork
    syscall
    
    test rax, rax
    jnz parent_process_2
    jz child_process

parent_process_2:

    # close(3)
    mov rdi, tunnel
    mov rax, 3 # sys_close
    syscall
    jmp parent_process_1

child_process:

    # close(3)
    mov rdi, sockfd
    mov rax, 3 # sys_close
    syscall

    # read(4, <read_request>, <read_request_count>) = <read_request_result>
    mov rdi, tunnel
    lea rsi, request
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov requestlen, rax

    # check GET or POST
    mov eax, request
    mov ebx, requestget
    cmp eax, ebx
    je handle_get
    mov ebx, requestpost
    cmp eax, ebx
    je handle_post

    jmp program_exit

handle_get:
    # open("<open_path>", O_RDONLY) = 3
    lea rdi, [request+4] # extract file name
    movb [rdi+16], 0
    mov rsi, 0 # O_RDONLY
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax

    # read(3, <read_file>, <read_file_count>) = <read_file_result>
    mov rdi, txtfile
    lea rsi, filecontent
    mov rdx, 1024
    mov rax, 0 # sys_read
    syscall
    mov filecnt, rax # 
    # close(3)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

    # write(4, <write_file>, <write_file_count>) = <write_file_result>
    mov rdi, tunnel
    lea rsi, filecontent
    mov rdx, filecnt
    mov rax, 1 # sys_write
    syscall

    jmp program_exit

handle_post:
    # open("<open_path>", O_WRONLY|O_CREAT, 0777) = 3
    lea rdi, [request+5] # extract file name
    movb [rdi+16], 0
    mov rsi, 0x41 # O_WRONLY | O_CREAT
    mov rdx, 0777
    mov rax, 2 # sys_open
    syscall
    mov txtfile, rax
    
    # locate POST body
    mov rcx, 0
    mov ebx, separate
locate_body:
    mov eax, [request+rcx]
    add rcx, 1
    cmp eax, ebx
    jne locate_body
    # extrace POST body
    add rcx, 3
    mov rdi, txtfile
    lea rsi, [request+rcx]
    mov rdx, requestlen
    sub rdx, rcx
    mov rax, 1 # sys_write
    syscall

    # close(3)
    mov rdi, txtfile
    mov rax, 3 # sys_close
    syscall

    # write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
    mov rdi, tunnel
    lea rsi, response
    mov rdx, 19
    mov rax, 1 # sys_write
    syscall

program_exit:
    # exit
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data

sockfd:   .quad 0
tunnel:   .quad 0
txtfile:  .quad 0
filecnt:  .quad 0
requestlen: .quad 0
request:  .space 1024
filecontent: .space 1024
requestget: .ascii "GET "
requestpost: .ascii "POST"
separate: .ascii "\r\n\r\n"
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"
sockaddr: .quad 0x50000002 # AF_INET(2) and PORT(80) in big endian
          .quad 0x0 # IP(0.0.0.0)
          .quad 0x0 # padding
          .quad 0x0 # padding
```

## Reverse Engineering Writeups

**Level 1**

运行/challenge下的文件，会自动打开gdb，输入`run`启动程序，进入第一关。第一关主要是讲下大致的题目要求，在这里按++c++继续运行会直接给出flag。

**Level 2**


本关run以后`p/x $r12`然后按++c++，把结果输入就行。

**Level 3**

这一关主要是熟悉打印内存数据，可以在按++c++进入程序前后用`x/20gx $rsp`对比一下栈上什么数据改变了。算是不看汇编的一点小trick。

**Level 4**

这关的没用正常解法。有一点小trick：使用`disas $pc`查看发现有个win函数，参数用的0。直接`set $rax=0`，`set $pc=xxx`跳转到win的函数就行了。

**Level 5**

这题提示可以编写gdb脚本，加载后会自动执行。这道题目会在循环中多次设置随机数，所以需要自动化解决。

run后先`disas $pc`看一看main函数的关键逻辑：

```
0x000055981a8ccd40 <+666>:   mov    esi,0x0
0x000055981a8ccd45 <+671>:   lea    rdi,[rip+0xd5e]        # 0x55981a8cdaaa
0x000055981a8ccd4c <+678>:   mov    eax,0x0
0x000055981a8ccd51 <+683>:   call   0x55981a8cc250 <open@plt>
0x000055981a8ccd56 <+688>:   mov    ecx,eax
0x000055981a8ccd58 <+690>:   lea    rax,[rbp-0x18]
0x000055981a8ccd5c <+694>:   mov    edx,0x8
0x000055981a8ccd61 <+699>:   mov    rsi,rax
0x000055981a8ccd64 <+702>:   mov    edi,ecx
0x000055981a8ccd66 <+704>:   call   0x55981a8cc210 <read@plt>
0x000055981a8ccd6b <+709>:   lea    rdi,[rip+0xd46]        # 0x55981a8cdab8
0x000055981a8ccd72 <+716>:   call   0x55981a8cc190 <puts@plt>
0x000055981a8ccd77 <+721>:   lea    rdi,[rip+0xd5a]        # 0x55981a8cdad8
0x000055981a8ccd7e <+728>:   mov    eax,0x0
0x000055981a8ccd83 <+733>:   call   0x55981a8cc1d0 <printf@plt>
0x000055981a8ccd88 <+738>:   lea    rax,[rbp-0x10]
0x000055981a8ccd8c <+742>:   mov    rsi,rax
0x000055981a8ccd8f <+745>:   lea    rdi,[rip+0xd51]        # 0x55981a8cdae7
0x000055981a8ccd96 <+752>:   mov    eax,0x0
0x000055981a8ccd9b <+757>:   call   0x55981a8cc260 <__isoc99_scanf@plt>
```

猜测在`0x000055981a8ccd51`处的open是打开了随机数发生器（比如/dev/urandom），然后`0x000055981a8ccd66`处的read是读8个字节，即最终的随机数，保存在rsi寄存器指向的位置，即rbp-0x18处。所以自动化脚本可以在`0x000055981a8ccd72`处（即*main+716）打个断点，打印此时rbp-0x18的值。

即先编写下述脚本，然后启动程序时-x追加脚本即可。

```shell
start
break *main+716
commands
    silent
    set $local_variable = *(unsigned long long*)($rbp-0x18)
    printf "Current value: %llx\n", $local_variable
    continue
end
continue
```

当然解法有很多，看disas后的结果，输入的数据被scanf保存到rbp-0x10处，与rbp-0x18比较。也可以在比较前直接修改寄存器让值相等。

**Level 6**

这一关才教怎么用set改寄存器，从而修改程序执行逻辑。是不是可以暗示直接拿flag？run后`set $rip=*main+715`，然后继续运行程序。

**Level 7**

？？？原来还可以这么玩？？

**Level 8**

直接调用`call (void)win()`，可以`disas *win`看一下win函数。

```
0x0000556609b49951 <+0>:     endbr64
0x0000556609b49955 <+4>:     push   rbp
0x0000556609b49956 <+5>:     mov    rbp,rsp
0x0000556609b49959 <+8>:     sub    rsp,0x10
0x0000556609b4995d <+12>:    mov    QWORD PTR [rbp-0x8],0x0
0x0000556609b49965 <+20>:    mov    rax,QWORD PTR [rbp-0x8]
0x0000556609b49969 <+24>:    mov    eax,DWORD PTR [rax]
0x0000556609b4996b <+26>:    lea    edx,[rax+0x1]
0x0000556609b4996e <+29>:    mov    rax,QWORD PTR [rbp-0x8]
0x0000556609b49972 <+33>:    mov    DWORD PTR [rax],edx
0x0000556609b49974 <+35>:    lea    rdi,[rip+0x73e]        # 0x556609b4a0b9
0x0000556609b4997b <+42>:    call   0x556609b49180 <puts@plt>
```

可见在`0x0000556609b49969`处，从rax指向的地址读取4字节。但是此时rax在前两条语句已经被修改为0了，所以触发NULL指针解引用，引起SIGSEGV退出。所以试试直接跳过这段，进入win时修改rip寄存器即可。

依次执行：`break *win`，`call (void)win()`，`set $rip=*win+35`，`c`即可。

**Level 1.0**

Reverse engineer this challenge to find the correct license key.

从此开始是一个证书验证程序，要求输入key来获取flag。第一题直接enter运行，会输出原始输入、处理后的输入以及正确答案。运行两次以后发现处理后的输入和原始输入是一样的，并且正确答案是固定的。

直接python里运行下`[chr(i) for i in [0x75,0x62,0x61,0x6a,0x68]]`（可能需要修改0xXX的值），然后就得到key了。

**Level 1.1**

Reverse engineer this challenge to find the correct license key.

这一题没有直接把正确答案列出来。一种方案是先gdb启动程序，然后在要求输入密钥的时候`ctrl+c`暂停程序，用`bt`查看调用栈，可以看到`__libc_start_main (main=0xXXXXX, argc=1, ....)`。然后查看main函数的汇编指令`x/80i 0xXXXX`，可以看到其中的memcmp@plt函数所使用的的rsi来自[rip+0x2abf]。指令后面的#注释提示了对应的地址，直接用`x/5c <address>`查看密钥即可。

注意最后输入密钥时要直接运行程序，不要在gdb里面输，会提示权限不够。


**Level 2.0**

Reverse engineer this challenge to find the correct license key, but your input will be modified somehow before being compared to the correct key.

这道题目交换了输入字符串的index 1和index 4的字符。

**Level 2.1**

这道题目在2.0的基础上隐去了输入输出结果的显示，因此需要gdb看一下做了什么操作。按照1.1的方法查看memcmp附近的函数，可见：

```asm
0x5584f463251f:      lea    rax,[rbp-0xe]
0x5584f4632523:      mov    edx,0x5
0x5584f4632528:      mov    rsi,rax
0x5584f463252b:      mov    edi,0x0
0x5584f4632530:      call   0x5584f46321a0 <read@plt>
0x5584f4632535:      movzx  eax,BYTE PTR [rbp-0xe]
0x5584f4632539:      mov    BYTE PTR [rbp-0x10],al
0x5584f463253c:      movzx  eax,BYTE PTR [rbp-0xd]
0x5584f4632540:      mov    BYTE PTR [rbp-0xf],al
0x5584f4632543:      movzx  eax,BYTE PTR [rbp-0xf]
0x5584f4632547:      mov    BYTE PTR [rbp-0xe],al
0x5584f463254a:      movzx  eax,BYTE PTR [rbp-0x10]
0x5584f463254e:      mov    BYTE PTR [rbp-0xd],al
0x5584f4632551:      lea    rdi,[rip+0xdb0]        # 0x5584f4633308
0x5584f4632558:      call   0x5584f4632140 <puts@plt>
0x5584f463255d:      lea    rax,[rbp-0xe]
0x5584f4632561:      mov    edx,0x5
0x5584f4632566:      lea    rsi,[rip+0x2aa3]        # 0x5584f4635010
0x5584f463256d:      mov    rdi,rax
0x5584f4632570:      call   0x5584f46321b0 <memcmp@plt>
```

输入的字符串被保存在[rbp-0xe]处，且进行了[rbp-0xe]和[rbp-0xd]的交换。也就是说输入字符串的前两个字符被交换了。查看memcmp加载到rsi的地址内容`x/5c 0x5584f4635010`得到对应的答案，交换前两个字符即可。

**Level 3.0-3.1**

运行程序，随便输几个数。显式告诉了规则是逆序，又把正确答案打印出来了。

3.1猜测和3.0一样也是逆序。直接按2.1的方法看一下[rbp-0xe]处的值然后逆序输入就行。

**Level 4.0-4.1**

规则是进行递增排序。这下只需要包含这些字母就行。（这不是更简单了……）

**Level 5.0-5.1**

这道题是对输入字符进行异或。简单写了个python，在控制台交互时运行下：

```python
tx = lambda x:int(x,16)
''.join([chr(i^0xb8) for i in [tx(a) for a in 'd6 d5 d6 cf da'.split() ]])
```

5.1和5.0类似，仿照之前的方法可以看到异或用的是0x1c。

**Level 6.0**

这道题结合了交换、异或、逆序三种操作，干脆写个脚本处理下吧。

```python
def do_reverse(li):
    return li[::-1]

def do_swap(li, idx1, idx2):
    li[idx1], li[idx2] = li[idx2], li[idx1]
    return li

def do_xor(li, key):
    xor_li = []
    while key > 0:
        xor_li.insert(0, key & 0xff)
        key >>= 8
    for i in range(len(li)):
        li[i] ^= xor_li[i % len(xor_li)]
    return li

def do_sort(li):
    li.sort()
    return li

def sanitize(s):
    if type(s) is str:
        f = lambda tx: int(tx,16)
        return [f(i) for i in s.split()]
    if type(s) is list:
        return ''.join([chr(i) for i in s])

print(sanitize(do_swap(do_xor(do_reverse(sanitize('51 90 52 86 58 98 4d 81 4b 84 4f 9a 57 8c 51 91 56')),0x3ef5),5,6)))
```

6.1有点奇怪，看汇编好像是先逆序一遍，再逆序一遍，再逐字节与0xbb异或。好像和5.0的置换-异或-逆序不一样的？可能是随机选择策略吧。

**Level 7.0-7.1**

7.0用上一个脚本即可。

```python
print(sanitize(do_swap(do_sort(do_xor(do_swap(do_xor(sanitize(' 16 34 42 00 13 31 46 0d 1c 3b 4e 15 05 22 52 10 04 22 54 1c 0f 2e 59 1d 0e 2f 5b'),0x85a4d396),13,16),0xf2)),7,10)))

```

7.1是先和0x15ca异或，然后逆序，然后再逆序，然后再逆序，然后再递增排序

```python
print(sanitize(do_xor(sanitize('60 61 64 66 67 6c 70 70 71 74 77 7c 7c 7d 7f a5 a5 a5 a8 ab ab af b0 b3 b8 b9 ba bb'),0x15ca)))
print(sanitize(do_xor(sanitize('60 61 64 66 67 6c 70 70 71 74 77 7c 7c 7d 7f a5 a5 a5 a8 ab ab af b0 b3 b8 b9 ba bb'),0xca15)))

#u«q¬r¦eºd¾b¶i·jo°o½a¾e¥y­s¯q
#ªt®s­yºe»a½i¶hµ°o°b¾aºz¦r¬p®
#然后把两个结果中字母排起来
#utqsryeedabiihjooobaaezyrspq
```


## 总结

CSE 365还是属于比较入门的类型，打好基础！