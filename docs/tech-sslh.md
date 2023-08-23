# sslh 阅读笔记

最近在读sslh的源码，感觉还是比较有意思的。之前在[端口复用](https://tech.c01dkit.com/porting/)里面简单提了下sslh的用法，但是在实践中踩了不少坑，所以把[源码](https://github.com/yrutschle/sslh)拿来读一读，看看内部的结构。

sslh似乎是使用第一个数据包保存的协议信息，为客户端与服务器对应服务建立连接。后续数据包不再需要检查协议了。

## 便捷上手

```shell
apt install sslh # 但最好还是从源码make install，用最新版本；参考仓库的INSTALL安装对应的C库
vi /etc/default/sslh
systemctl start sslh
```

似乎cfg文件里和command line会有冲突。所以commandline用`-F /etc/sslh/sslh.cfg`（没有则新建一个）指定的配置文件中，不要有和command重复的内容。只放protocols差不多就得了。比较好用的是正则和tls中根据alpn和sni来匹配。

下面是**完整的配置文件**的一个例子，如果数据包包含"OK1"或者"OK2"，则会被转发到127.0.0.1:1234。其中的name字段表示这条协议在sslh启动后怎么配置，常见的比如`regex`、`ssh`、`tls`、`http`。

注意，最后一条协议的分号后面不加逗号。

```c
protocols:
(
    { name: "regex"; host: "127.0.0.1"; port: "1234"; regex_patterns: [ "OK1", "OK2" ]; }
);
```

## sslh程序启动入口与初始化

默认最简单的启动方式的入口在`sslh-main.c`的main函数，也即程序的主体逻辑。一些关键步骤：

1. 调用`sslhcfg_cl_parse`函数，根据命令行参数和配置文件，做一个缓冲
2. 调用`config_protocols`完成转发规则的初始化，内部调用的`get_probe`是给加载了协议的配置规则
3. 调用`start_listen_sockets`开始监听sockets
4. 调用`main_loop`进入主循环，默认为sslh-fork的main_loop函数

默认使用tcp。main_loop函数中，对监听的每个sockets进行fork，每个子进程执行`tcp_listener`，在这些子进程中`accept`对应的连接。这些子进程将继续fork出子进程，执行`start_shoveler`，实现真正的功能。

## 协议识别

子进程通过`probe_client_protocol`来确定数据包是什么协议，并根据对应的规则实现端口转发。这一函数不断进行调用，最后在`probe_buffer`函数中遍历之前配置的每个协议规范（找到匹配则停止，所以配置顺序也蛮关键的），通过`p->probe(buf, len, p)`这个函数指针来间接调用识别协议的相关函数。

这里的协议包括以下内置协议：

```c
/* Table of protocols that have a built-in probe
 */
static struct protocol_probe_desc builtins[] = {
    /* description  probe  */
    { "ssh",        is_ssh_protocol},
    { "openvpn",    is_openvpn_protocol },
    { "wireguard",  is_wireguard_protocol },
    { "tinc",       is_tinc_protocol },
    { "xmpp",       is_xmpp_protocol },
    { "http",       is_http_protocol },
    { "tls",        is_tls_protocol },
    { "adb",        is_adb_protocol },
    { "socks5",     is_socks5_protocol },
    { "syslog",     is_syslog_protocol },
    { "teamspeak",  is_teamspeak_protocol },
    { "msrdp",      is_msrdp_protocol },
    { "anyprot",    is_true }
};
```



内置协议内置了一些匹配规则，即上面提到的`is_ssh_protocol`、`is_http_protocol`等等。可以看一个ssh规则的例子：

```c
/* Is the buffer the beginning of an SSH connection? */
static int is_ssh_protocol(const char *p, ssize_t len, struct sslhcfg_protocols_item* proto)
{
    if (len < 4)
        return PROBE_AGAIN;

    return !strncmp(p, "SSH-", 4);
}
```

可见，如果第一个数据包长度不低于4且以"SSH-"开头，则会被认为是ssh请求。


```c
/* Is the buffer the beginning of an HTTP connection?  */
static int is_http_protocol(const char *p, ssize_t len, struct sslhcfg_protocols_item* proto)
{
    int res;
    /* If it's got HTTP in the request (HTTP/1.1) then it's HTTP */
    if (memmem(p, len, "HTTP", 4))
        return PROBE_MATCH;

#define PROBE_HTTP_METHOD(opt) if ((res = probe_http_method(p, len, opt)) != PROBE_NEXT) return res

    /* Otherwise it could be HTTP/1.0 without version: check if it's got an
     * HTTP method (RFC2616 5.1.1) */
    PROBE_HTTP_METHOD("OPTIONS");
    PROBE_HTTP_METHOD("GET");
    PROBE_HTTP_METHOD("HEAD");
    PROBE_HTTP_METHOD("POST");
    PROBE_HTTP_METHOD("PUT");
    PROBE_HTTP_METHOD("DELETE");
    PROBE_HTTP_METHOD("TRACE");
    PROBE_HTTP_METHOD("CONNECT");

#undef PROBE_HTTP_METHOD

    return PROBE_NEXT;
}
```

http也比较简单，检查"HTTP"字符串。


另外有两种特殊的协议，timeout默认会选择初始化后的第一个协议（即ssh），regex支持正则匹配数据包的固有字符串，就连初始化时都是单独初始化的：

```c
/* Returns the probe for specified protocol:
 * parameter is the description in builtins[], or "regex" 
 * */
T_PROBE* get_probe(const char* description) {
    int i;

    for (i = 0; i < ARRAY_SIZE(builtins); i++) {
        if (!strcmp(builtins[i].name, description)) {
            return builtins[i].probe;
        }
    }

    /* Special case of "regex" probe (we don't want to set it in builtins
     * because builtins is also used to build the command-line options and
     * regexp is not legal on the command line)*/
    if (!strcmp(description, "regex"))
        return regex_probe;

    /* Special case of "timeout" is allowed as a probe name in the
     * configuration file even though it's not really a probe */
    if (!strcmp(description, "timeout"))
        return is_true;

    return NULL;
}
```

`is_true`始终返回true，不进行别的判断了。

`regex_probe`内部用pre2实现了一套正则匹配的机制。配置config的方法可以见上文。

## TLS协议中使用的ALPN、SNI简介

tls为tcp提供了加密服务，是很多服务不可或缺的一环。由于数据包是加密的、很多服务都使用tls（比如https），所以没法通过regex的方法来区分不同的服务。好在sslh为tls提供了两种分辨方法，即sni_hostnames与alpn_protocols。在config里写的一条规则如果两者都用了，则只有同时满足两者的tls数据包才匹配得上对应的规则。

比如example.cfg给出的例子：

```shell
# match BOTH ALPN/SNI
     { name: "tls"; host: "localhost"; port: "5223"; alpn_protocols: [ "xmpp-client" ]; sni_hostnames: [ "im.somethingelse.net" ]; log_level: 0; tfo_ok: true },

# just match ALPN
     { name: "tls"; host: "localhost"; port: "443"; alpn_protocols: [ "h2", "http/1.1", "spdy/1", "spdy/2", "spdy/3" ]; log_level: 0;  tfo_ok: true },
     { name: "tls"; host: "localhost"; port: "xmpp-client"; alpn_protocols: [ "xmpp-client" ];  log_level: 0; tfo_ok: true },

# just match SNI
     { name: "tls"; host: "localhost"; port: "993"; sni_hostnames: [ "mail.rutschle.net", "mail.englishintoulouse.com" ]; log_level: 0;  tfo_ok: true },
     { name: "tls"; host: "localhost"; port: "xmpp-client"; sni_hostnames: [ "im.rutschle.net", "im.englishintoulouse.com" ];  log_level: 0; tfo_ok: true },

# Let's Encrypt (tls-alpn-* challenges)
     { name: "tls"; host: "localhost"; port: "letsencrypt-client"; alpn_protocols: [ "acme-tls/1" ]; log_level: 0;},

# catch anything else TLS
     { name: "tls"; host: "localhost"; port: "443";  tfo_ok: true },
```

alpn_protocols即使用应用层协议协商编号：TLS Application-Layer Protocol Negotiation (ALPN) Protocol ID。可以在[这里](https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml#alpn-protocol-ids)看到完整的格式。打个比方，如果说数据包是饺子，tls是饺子皮，ALPN就是表示里面是什么馅的。

sni_hostnames即使用服务器名称指示：Server Name Indication（SNI），类似于服务器端的域名。打个比方，虽然在学校快递（数据包）都会送到菜鸟驿站（服务器），但这些包裹最终是流向不同的宿舍的（SNI）。SNI帮助在tls握手期间就确定ssl证书，而不是在http建立连接后。FQDN指的是Fully Qualified Domain Name，即完整域名，可以看[这里](https://www.hostinger.com/tutorials/fqdn#Examples_of_an_FQDN)的介绍。

sni_hostname和alpn_protocols，属于tls扩展内容，并非强制保留其中。发包的时候注意添加，不然sslh可能识别不到。