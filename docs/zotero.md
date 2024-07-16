# Zotero 配置

Zotero是非常好用的文献管理工具！可以[在这里下载](https://www.zotero.org/)

## Zotfile 插件配置

zotfile是必备插件，可以帮助管理pdf文件保存位置、自动重命名等，结合其他的一些云同步软件可以突破WebDav的文件存储限制，可以[在这里下载](https://zotfile.com/)

[这里是非常详细的配置说明](https://pkmer.cn/Pkmer-Docs/11-zotero/zotero%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8/4_%E5%90%8C%E6%AD%A5%E4%B8%8E%E5%A4%87%E4%BB%BD/4_2_%E9%80%9A%E8%BF%87-zotfile-%E4%B8%8E%E7%AC%AC%E4%B8%89%E6%96%B9%E7%BD%91%E7%9B%98%E5%A4%87%E4%BB%BD/)，可以参考它来完成配置。

在不使用WebDav的情况下，如果本地有其他云盘（比如WPS、OneDrive、Dropbox）等，可以用这些云盘提供的大容量存储功能。比较关键的就是zotfile配置里的General Settings->Custome Location指定到本地云同步的某个文件夹，同时Zotero设置里Advanced->Files and Folders->Linked Attachment Base Directory->Base directory设置为相同的文件夹。

然后每当添加文件后，右键条目选择Manage Attachment->Rename and Move即可自动移动到这个文件夹里，同时不会占用Zotero账户的300MB空间。切换电脑时，由于条目元数据是同步的，所以只需要设置一下base directory并且用云盘同步一下文件，就可以在zotero里打开了。

## Zotero Style 插件配置

这个style插件可以在标题上显示阅读进度条、更改pdf阅读背景色等等，也支持井号添加自定义标签并显示在zotero目录里，非常好用！可以在[这里下载](https://github.com/MuiseDestiny/zotero-style)

