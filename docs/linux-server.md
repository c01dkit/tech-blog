# linux服务器运维

## 根据pid查询细节

```shell
sudo ls -lah /proc/<pid>
```
然后根据其中的cwd找到运行目录，exe找到运行程序

## 在linux终端向程序输入字节

```shell
# 输入raw bytes
echo -e '\x31\x32' | program

# 输入raw binary
echo -e '\x31\x32' | xxd -r -p | program 
```