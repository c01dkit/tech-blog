# Docker使用笔记

## 创建容器并挂载目录

会在容器中创建目录，映射宿主机目录。宿主机的目录和容器目录内容是一样的，修改一方，另一方随之改变

```shell
docker run -it --name=xxxx --mount type=bind,source=<宿主机目录>,target=<容器目录> <镜像名>:<tag> /bin/bash
```

## 进入已有的容器

```shell
docker exec -it <容器id> /bin/bash
```

可以++ctrl+d++退出

## 退出初次创建的容器

使用++ctrl+p+q++退出容器。否则简单退出后容器就stop了，下次exec的时候还要restart，甚至还会出现restart自动又stop的情况