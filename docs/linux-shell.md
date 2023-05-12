# linux 常用命令学习

## 在linux终端向程序输入字节

```shell
# 输入raw bytes
echo -e '\x31\x32' | program

# 输入raw binary
echo -e '\x31\x32' | xxd -r -p | program 
```