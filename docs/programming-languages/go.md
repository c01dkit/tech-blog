# go

Go 语言（Golang）是一种静态类型、编译型、并发支持良好的编程语言，特别适用于系统编程、后端开发、云计算和微服务架构等场景。

## 快速入门

### go环境配置

1. 从[https://go.dev/dl/](https://go.dev/dl/)下载Archive的包，解压缩（比如到~/.local），添加其中的bin目录到PATH路径
2. 国内使用时设置代理

```shell
go env -w GO111MODULE=on
go env -w  GOPROXY=https://goproxy.cn
```

### 创建工程

工程保存在xxx/go/src/xxx下，并将GOPATH=xxx/go加到环境变量中


### 概览

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

## 第一阶段：Go 语言基础

### 入门与环境搭建
- Go 语言的特点与应用场景
- 安装 Go 语言（官方安装包/包管理工具）
- 配置 Go 开发环境（VS Code、GoLand、命令行工具）
- `go` 命令工具的使用（`go run`、`go build`、`go fmt`、`go mod`）

### **2. Go 语言基础语法**
- Go 的基本数据类型（`int`、`float`、`string`、`bool`等）

**变量与常量（`var`、`:=` 短变量声明、`const`）**

```go
var power int // 定义一个int类型的变量，名称为power
powers := 1000 // 使用 := 省略变量类型（自动推断）
powers, newpower := 100, 101 // := 如果一个变量已经定义过，不能使用 := 重新定义，但在多赋值场景下，只要有一个没定义过就可以了


```


- 基本运算符与表达式（算术、逻辑、比较运算符）
- 流程控制语句（`if`、`switch`、`for` 循环）
- `defer` 语句的用法

### 函数与作用域

**Go 函数的定义与调用**




- 多返回值函数
- 可变参数函数
- 匿名函数与闭包
- 作用域与变量生命周期



## **第二阶段：深入理解 Go 语言**
### **4. 复合数据类型**
- 数组（`[size]T`）与切片（`[]T`）
- 切片的底层原理（容量、扩容机制）
- `map`（字典）与 `make` 关键字
- 结构体（`struct`）与方法
- 指针与引用（值传递 vs. 引用传递）

### **5. 面向对象编程**
- 方法与 `struct` 结合
- 组合代替继承（Go 语言不支持类继承）
- 接口（`interface`）与多态
- 空接口（`interface{}`）与 `type assertion`
- 反射（`reflect` 包）

### **6. 并发编程**
- Goroutines（轻量级线程）
- `sync.WaitGroup` 用于等待 Goroutine 结束
- `channel` 的基本使用（无缓冲/有缓冲）
- `select` 语句处理多个 `channel`
- `sync.Mutex` 互斥锁
- `sync.Cond`、`sync.Map` 等高级并发工具


## **第三阶段：Go 语言进阶**
### **7. Go 语言标准库**
- `fmt`（格式化输入输出）
- `strings`（字符串处理）
- `strconv`（字符串与其他类型转换）
- `time`（时间处理）
- `os`（文件系统操作）
- `io` 与 `bufio`（输入输出流）
- `log`（日志处理）
- `encoding/json`（JSON 解析与序列化）
- `net/http`（HTTP 服务器与客户端）

### **8. Go 语言项目管理**
- `go mod` 依赖管理
- `go test` 编写和运行单元测试
- `go benchmark` 性能测试
- `pprof` 性能分析

### **9. Go 语言高级特性**
- 泛型（Go 1.18+ 支持）
- Context（`context.Context` 用于超时控制、取消信号）
- `unsafe` 包（底层内存操作）
- FFI（Foreign Function Interface，与 C 语言交互）

## **第四阶段：项目实战与最佳实践**
### **10. Web 开发**
- Go 语言 HTTP 服务器（`net/http`）
- Web 框架 Gin（路由、中间件、JSON 处理）
- RESTful API 设计
- JWT 认证与 OAuth2
- 数据库操作（`gorm` ORM 框架）
- 配置管理（`viper`）

### **11. 微服务架构**
- gRPC（Protocol Buffers + Go）
- 消息队列（Kafka、RabbitMQ）
- Kubernetes（K8s）与 Docker 容器化部署
- API 网关（Kong、Envoy）

### **12. 云计算与分布式系统**
- 分布式存储（Etcd、Redis）
- 分布式任务调度（CronJob、Celery）
- 高并发处理（负载均衡、限流熔断）

## **第五阶段：深入源码与优化**
### **13. Go 语言源码解析**
- Go 语言编译器（GC 编译器、LLVM）
- Go 运行时（runtime 包）
- Goroutine 调度器（GMP 模型）
- 内存管理（垃圾回收机制）

### **14. Go 语言性能优化**
- CPU Profiling（`pprof`）
- 内存泄漏分析（`heap dump`）
- 减少 GC 负担（对象池、sync.Pool）
- 并发优化（减少锁冲突）

## **学习资源推荐**
### **官方文档**
- [Go 官方文档](https://golang.org/doc/)
- [Go 简易教程](https://learnku.com/docs/the-little-go-book/getting_started/3295)
- [Go by Example](https://gobyexample.com/)
- [Go 语言标准库](https://pkg.go.dev/)

### **书籍**
- 《The Go Programming Language》（Go 语言圣经）
- 《Go in Action》
- 《Go 语言高级编程》
- 《Go Web 编程》

### **在线教程**
- [Go 官方 Tour](https://tour.golang.org/)，教程+在线编译，在调试中学习
- [Go Dev](https://dev.to/t/golang)
- [Go Patterns](https://github.com/tmrts/go-patterns) (最佳实践)
- [Effective Go](https://go.dev/doc/effective_go)