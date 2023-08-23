# go

## go环境配置

1. 从[https://go.dev/dl/](https://go.dev/dl/)下载Archive的包，解压缩，添加其中的bin目录到系统路径
2. 国内使用时设置代理

```shell
go env -w GO111MODULE=on
go env -w  GOPROXY=https://goproxy.cn
```

## 快速入门

```go
package main
import (
    "fmt"
)
//循环输出
for i:=0; i<10; i++{
    fmt.Println(i)
}

```