# 20230514 用于自动化分析docs目录下文件结构，更新index.md文件

from pathlib import Path
import yaml
import re
import datetime
# 读取docs目录下所有md文件
def get_md_files():
    md_files = []
    for file in Path('docs').glob('**/*.md'):
        md_files.append(file)
    return md_files

# 读取mkdocs.yml文件，获取nav配置
def get_nav():
    with open('mkdocs.yml', 'r', encoding='utf-8') as f:
        mkdocs_yml = yaml.load(f, Loader=yaml.FullLoader)
        nav = mkdocs_yml['nav']
    return nav

# 读取md文件，返回标题
def get_md_titles(md_file):
    titles = []
    blocks = False
    with open(md_file, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('```') and not blocks:
                blocks = True
            elif line.startswith('```') and blocks:
                blocks = False
            if blocks:
                continue
            # 使用正则判断是否为标题
            if re.match(r'^#{1,6} ', line):
                titles.append(line.replace('#', '').strip())
    return titles

# 根据mkdocs的规则，将标题格式化为锚点命名
# 原理为只保留字母、数字，使用短划线连接空格，如果有重复，则给之后的标题加上下划线和序号（从1开始）
def reformat_locators(titles):
    result = []
    for title in titles:
        locator = title.lower().replace(' ', '-')
        # 设置允许保留的字符
        allowed = 'abcdefghijklmnopqrstuvwxyz0123456789-_'
        locator = ''.join([c for c in locator if c in allowed]).strip('-')
        if locator in result or len(locator) == 0:
            i = 1
            while True:
                if locator+'_'+str(i) in result:
                    i += 1
                else:
                    locator = locator+'_'+str(i)
                    break
        result.append(locator)
    return result

# 遍历nav，打印文件
def generate_index(nav, md_files, titles):

    if isinstance(nav, list):
        for item in nav:
            generate_index(item, md_files, titles)
    elif isinstance(nav, dict):
        for key in nav:
            data = nav[key]
            if isinstance(data, list):
                titles.append(key)
                generate_index(data, md_files, titles)
                titles.pop()
            elif isinstance(data, str):
                if data == 'index.md':
                    continue
                for md_file in md_files:
                    if md_file.name == data:
                        lines = get_md_titles(md_file)
                        locators = reformat_locators(lines)
                        stem = md_file.stem
                        lines = lines[1:]
                        locators = locators[1:]
                if len(lines) > 0:
                    titles.append(key)
                    result.append('\n## '+' / '.join(titles)+'\n\n')
                    titles.pop()
                    for i in range(len(lines)):
                        # 生成md文件的链接，使用相对路径，起始地址为'./'
                        result.append('- ['+lines[i]+']'+'(./'+stem+'/#'+locators[i]+')\n')
    return result
result = [f"""# Welcome to c01dkit's tech blog

目录为自动生成，可能有误。最近一次更新时间{datetime.datetime.now().strftime('%Y-%m-%d')}。
          
[欢迎提issue以指错、交流](https://github.com/c01dkit/tech-blog/issues)！

最近一次更新内容：

* 新增《文章阅读》版块，收录了一些文章链接
* 新增了sslh项目的阅读笔记
* 更新pwn-college CSE 365的部分wp
* 一些其他页面的更新

"""]
mds = get_md_files()
nav = get_nav()
result = generate_index(nav, mds, [])
with open('docs/index.md', 'w', encoding='utf-8') as f:
    f.writelines(result)