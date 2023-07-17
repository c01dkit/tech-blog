# Docker使用笔记

## 安装docker

按照[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)的说明安装即可

## 指定镜像保存位置

默认使用的位置是`/var/lib/docker`，在根目录下容易占满。可以通过修改配置文件`/lib/systemd/system/docker.service`的-g参数来指定位置。可以通过`docker info`查看保存的位置Docker Root Dir。

配置文件可以通过`systemctl status docker`并查看Load使用的配置文件是哪个。

另一种指定镜像保存位置的方法：修改/etc/docker/daemon.json，设置为

```json
{
  "data-root": "/home/docker"
}
```

随后重载一下配置：

```shell
sudo cp -r /var/lib/docker /home/docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl status docker
```

## 从镜像创建容器并挂载目录

会在容器中创建目录，映射宿主机目录。宿主机的目录和容器目录内容是一样的，修改一方，另一方随之改变

```shell
docker run -it --name=<container_name> --user=<user_id>:<group_id> --hostname=xxxx --workdir=xxxx  -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro --mount type=bind,source=<宿主机目录>,target=<容器目录> <镜像名>:<tag> /bin/bash
```
以上命令可以完成对指定镜像创建一个比较完备的容器，指定了容器名称、用户名称和组别、主机名、用户工作目录，并挂载了主机的一些目录。指定passwd和group文件的只读挂载可以避免--user使用用户(组)id进行新建容器时引发的找不到用户名和组名的问题。并且避免了默认root用户导致的主机端无法访问容器新建文件的问题。

注意这样创建的用户没有root权限。如果需要，则不使用user参数，但存在容器创建文件是root，宿主机无法修改的问题。

一个不太聪明的解决方法是user_id设成root的0，group_id设成普通用户，然后在容器里给root的.bashrc加一行umask 0002。就是说让用户组也能修改文件了。

一些其他的办法：`docker exec -u`好像可以指定启动容器时的用户，不知道有什么用，可以试试；或者root进去以后把普通用户加到sudoers里

## 新容器初始化

`apt-get update`更新一下list，然后才能使用apt-get下载其他包。一些常用的包：`apt-get install build-essential`

## 退出初次创建的容器

连按++ctrl+p++、++ctrl+q++退出容器。否则简单退出后容器就stop了，下次exec的时候还要restart，甚至还会出现restart自动又stop的情况

## 进入已有的容器

```shell
docker exec -it <容器id> /bin/bash
```

可以++ctrl+d++退出

