# go

## go环境配置

1. 从[https://go.dev/dl/](https://go.dev/dl/)下载Archive的包，解压缩（比如到~/.local），添加其中的bin目录到PATH路径
2. 国内使用时设置代理

```shell
go env -w GO111MODULE=on
go env -w  GOPROXY=https://goproxy.cn
```

## 创建工程

工程保存在xxx/go/src/xxx下，并将GOPATH=xxx/go加到环境变量中


## 快速入门

```go
package main
import (
    "fmt"
)

func main() {
    //循环输出
    for i:=0; i<10; i++{
        fmt.Println(i)
    }
}

```