# Git学习笔记

## 将本地已有仓库推送至Github的新建仓库中

默认以下条件均成立：

* 已在github上创建同名空仓库（不同名也行）
* 已配置好ssh密钥
* 已建立好本地仓库（`git init` +`git add .` +`git commit -m "comments"`)
* 本地仓库为clean状态（使用`git status`查看）

1. 进入本地git仓库，使用`git remote add origin git@github.com:xxx(仓库网站比如github提供的ssh地址)`
2. 使用`git push -u origin master`向远程仓库提交代码（后来听说github默认名改成main了？）

强制推送可以再加个`--force`参数

## 添加.gitignore文件以不追踪文件

初次向github提交代码前，在本地工作目录下创建.gitignore文件，里面直接写上不想追踪的文件名和文件夹名即可。（文件名不需要补全路径）

## 放弃对文件的跟踪

与他人合作项目时，有时需要做一些本地适配，但是不想妨碍其他人，可以添加到.gitignore。但对于已经处于跟踪状态的文件来说后添进.gitignore是无效的。因此可以先将文件移出跟踪态，然后再加进.gitignore里。如下：`git rm -r --cached <file/dir>`其中-r表示递归。也可以加-n表示伪放弃跟踪（用于预览会放弃对哪些文件的追踪）

## 撤回add

使用`git add .`可以直接把当前目录都add进暂存区，对于不慎添加的内容可以使用`git rm --cached <file>`来撤回add。可以使用`git rm -r --cached .`来撤回`git add .` 。（使用`git status`可以查看暂存区，里面也有提示怎么撤回）

## 配置git账号并加入github项目

1. 使用`git config --global user.name "<yourname>"`设置用户名
2. 使用`git config --global user.email "<email>"`设置邮箱
3. 使用`ssh-keygen -t rsa -C "<comments>"`生成密钥对，然后一路回车直到生成结束（也可以提示添加passwd phrase，这样的话如果使用ssh-add添加时会要求输入这个密码防止被别人滥用。注意相同的passwd phrase不会生成相同的密钥对）
4. 在上一步过程中默认的路径（比如~/.ssh）找到id_rsa.pub文件，拷贝其全部内容
5. 打开github，右上角头像，settings，左侧的SSH and GPG keys，然后给SSH添加这个公钥即可

ed25519似乎比默认的rsa更安全、计算更快、密钥更短，可以使用

有时需要指定密钥，比如不使用默认的密钥文件名。此时可以先`eval $(ssh-agent -s)`启用agent，然后`ssh-add <private keyfile>` 来添加密钥。`ssh-add -l`可以查看添加的密钥。

或者可以把密钥在`~/.ssh/config`文件里指定一下，就可以省去ssh-agent的操作，比如

```text
Host github.com
    HostName github.com
    IdentityFile ~/.ssh/id_ed25519_user_github
```

有的时候git进行push到私仓时会出现卡机的问题，不确定是什么原因，如果remote repo使用的是git@xxx的url的话，可以试试改成https的链接；还不行的话可以试试git config的proxy，设置或清空。



## 清理未跟踪文件

如果需要清理仓库，恢复到刚克隆的纯净状态，可以执行`git clean -d -fx`。例如，在`git reset --hard <commit id>`后，如果希望将多余文件删掉，可以执行这行命令。`-d`会删除未跟踪的目录，`-x`会删除被.gitignore忽略的文件。

如果本地不知道改了什么但是想强行和最新分支（主线）同步，可以直接`git reset --hard <commit name>`然后`git checkout <commit name>`、`git pull`。

## 更换远程仓库

有的时候从官方仓库git clone下代码，本地拷贝一份、各种魔改并上传到自己的私仓。又由于windows、linux环境不同，想把原来的代码更新成自己的私仓，所以需要换一下远程仓库。

1. 首先取消原来的远程分支跟踪`git remote remove <remote repo name>`
2. 然后添加自己的仓库作为远程`git remote add <remote repo name> <repo url>`

也可以直接更换远程仓库：`git remote set-url <remote repro name> <repo url>`

这里的`<remote repo name>`是自己取的仓库名，之后的操作可以用它来指定对象。可以随便取，比如常见的origin。

或者也可以不取消原来的跟踪，直接取一个新的name即可，比如gitee、github、myrepo等等。

## 子模块的下载

有的时候一个代码仓库拿其他仓库来当做子模块，在github上这些模块是图中的表示形式。git仓库里也会有.gitmodules文件来说明这些子模块。当clone主仓库时，这些子模块不会跟着下载下来。

初次部署时，在主仓库目录下里使用`git submodule update --init --recursive`来从.gitmodules字clone子模块。

如果子模块被别的开发者更新了，可以进到子模块中然后`git pull`。

如果希望添加某个仓库作为子模块，使用`git submodule add <repo url>`来下载子模块并更新.gitmodules文件

## 自己的项目需要对其他项目进行修改

如果自己的项目用到别的项目，需要对其中一些代码进行修改，而不需要把在上传github时把整个项目全部放到自己的项目下，可以先用submodule添加子模块，然后直接修改代码，并在其项目下用`git diff <commit id> > <file.patch>`生成一个diff文件。把diff文件放到自己的项目里，再上传到github上。其中commit id是第三方项目的commit，也就是这个submodule下载时的commit id，可以通过`git log`找到。

如果直接用`git diff > <file.patch>`，会输出未加入暂存的修改和最近一次暂存/commit的diff文件。

其他人使用时，就先把第三方项目获取下来，然后`git apply <file.patch>`即可。撤回补丁使用`git apply -R <file.patch>`

## 不同版本多人合作与分支使用

最近在跑fuzzer，合作时有时需要切换不同的测试目标，每个测试目标都有自己的一大堆配套设置。大家都在主分支删改太麻烦而且很乱，所以需要针对每个测试目标设置不同的branch。

可以使用`git branch -a`查看所有分支。其中前面带`*`的是当前branch。

**新建分支**时使用 `git checkout -b <branch name>` 相当于先`git branch <branch name>` 创建了一个新的分支，然后`git checkout <branch name>`切换到那个分支。

在新的分支commit后，使用`git push -u <remote repo name> <local branch name>:<remote branch name>`可以将自己的这个分支推送到远程仓库。其中：

*  `-u`表示记住当前设定，之后在这一分支上push时，简单使用`git push`就会推送，不需要再敲这么长了。
*  origin 是之前`git remote add origin` 设定的远程主机名称，需要和实际设定一样。因为大家使用origin是在太普遍了，所以这里没有用`<remote host name>`来表示，意会即可。
*  local branch name和remote branch name一般情况是相同的。会在远程新建remote branch name

如果需要删除远程分支，可以简单地推送空分支：`git push origin :<remote branch name>`。这里本地分支名留空了。也可以使用专门的删除方式：`git push origin --delete <remote branch name>`

如果需要删除本地分支，使用`git branch -d <local branch name>`

合并分支时，先切换到需要接收改动的分支上，然后`git merge <new branch name>`，即可将new branch的改动更新到当前分支上。new branch的内容是不变的。

拉取远程分支到本地，而不影响本地分支：`git fetch <remote repo name> <remote branch name>:<local branch name>`会将远程仓库的分支保存在本地对应分支下。

可以用`git fetch --all`拉取所有远程分支，如果没有效果，注意检查remote.origin.fetch的设置：`git config --get remote.origin.fetch`，如果是`+refs/heads/master:refs/remotes/origin/master`，则表示只拉master分支。可以修改成拉取所有分支：`git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"`。

## Git rebase 合并本地多个commits

这里先写一种最简单的场景，比如本地修改完commit之后发现还有要改的，又commit了一次，现在需要合并两个commits。在该分支上运行`git rebase -i HEAD~N` 其中N是从HEAD起向前需要合并的commit数。随后文本框里会显示各个commits信息，从上到下的commits时间从旧到新。保留最上面的commit为pick，下面的都改为squash（合并message，适用于两个commit都有实际信息量）或fixup（丢弃该message，适用于新commit是typo等没必要留在最终提交记录的内容），即相当于把后面的commits向前合并到最上面的那一个commit。如果遇到冲突，可以修复后`git rebase --continue`。如果需要放弃，就`git rebase --abort`。

## 减少冗余commits

有的时候本地commit后发现有一点小typo需要修改，这时：
1. 如果还没有运行新的git commit，就可以先git add然后`git commit --amend --no-edit`来将工作区合并到之前的commit里；
2. 如果已经commit但还没有push，可以用`git rebase -i HEAD~2`，然后按之前的教程来编辑；
3. 如果已经push了，就在本地rebase好以后用`git push --force-with-lease`，注意不要用`--force`。

## 自行构建git仓

有时git仓库不想用github、gitee等管理，又想做到多地存储，可以自行构建一个git中心仓库：

```shell
# 在中心服务器上创建裸仓
git init --bare 

# 如果中心服务器已有仓库，可以直接clone导出
git clone --bare /path/to/repo /path/to/bare/reponame.git

# 在本地服务器上关联远程服务器的裸仓
git remote add origin ssh://username@remote-ip:port/path/to/target.git

# 在本地服务器关联本地裸仓
git remote add origin /path/to/bare/reponame.git

# 在本地服务器clone本地裸仓
git clone /path/to/repo.git 
```

然后就可以正常使用。



## Github debug合集

某种东西真的神烦，科研需要下载的仓库代码经常莫名其妙下载不了，写的代码上传补上去，build个docker慢的要死，第三方包拉取不到……浪费很多时间在因为网络连接不了导致的各种bug上，有效科研时间白白被消耗，真的很xx。

### git clone报错gnutls_handshake() failed: The TLS connection was non-properly terminated.

一种做法是设置或者取消设置http.proxy和https.proxy

另一种做法是直接取消SSL校验，虽然粗暴了点：`git config http.sslVerify false`

还有就是`git@`不行换`https://`来下载

### git add 报错fatal: CRLF would be replaced by LF in xxx

有的时候不小心在windows powershell进行仓库管理，但是代码又要在linux场景运行，代码编辑会遇到换行符的问题。以下是解决办法：

创建`.gitattributes`文件，里面写`* text=auto eol=lf`。然后在linux（wsl）中运行：


```bash
git config core.autocrlf false
git config core.eol lf
git add --renormalize .
git commit -m "fix eol"
git rm --cached -r .
git reset --hard
```

可以通过运行`git ls-files --eol`来检查git记录和工作区状态。例如

```bash
i/lf    w/lf    attr/text=auto         src/main.py
i/lf    w/crlf  attr/text=auto         README.md
i/crlf  w/crlf  attr/text=auto         old.txt
```

其中`i/`表示index里git记录的行尾状态，`w/`表示文件实际行尾状态，`attr/`表示对这个文件生效的规则。当`i/`和`w/`全是`lf`时，说明没有问题了。

然而，如果在windows中添加了新文件，由于CRLF，他们根本不会被纳入git管理。因此可以执行`git ls-files --others --exclude-standard`看一下有那些文件，然后进行物理替换：`git ls-files --others --exclude-standard -z | xargs -0 sed -i 's/\r$//'`。