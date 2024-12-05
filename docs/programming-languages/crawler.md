# 爬虫模板

## Scrapy

也可以看[这里](https://blog.csdn.net/weixin_43483799/article/details/126014266)的介绍

### 加国内代理

针对个别网站锁ip，可以考虑整个[代理](https://www.kuaidaili.com/?ref=omalu62gst3l)

```python
import base64
username = 'xxxxx'
passwd = 'xxxxx'
proxy_ip = 'xxxx.kdltps.com'
proxy_port = '15818'

meta = {'proxy': f'http://{proxy_ip}:{proxy_port}'}
code = base64.b64encode(f'{username}:{passwd}'.encode()).decode()

headers = {
	"Proxy-Authorization": f"Basic {code}", # 在headers里设置下代理token
}

def start_requests(self):
	yield scrapy.Request(
		headers = headers, # 设置使用headers，包含token
		meta = meta, # 设置使用代理
		)
```

### application/json类型

针对请求头Content-Type为application/json类型，start_requests里用Request，注明method和body：

```python
import json
headers = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
}

data = json.dumps({"key":"value"})

# 省略无关信息

yield scrapy.Request(
    url=url, 
    method='POST', 
    headers=headers, 
    body=data,
    callback=self.parse, 
    meta={'period': t}, 
    errback=self.err,
    cb_kwargs={'period': t,'page':0}
)

```

### application/x-www-form-urlencoded类型

针对请求头Content-Type为application/x-www-form-urlencoded类型，start_requests里用FormRequest，注明formdata：

```python

post_data = {"key":"value"}

# 省略无关信息

yield scrapy.FormRequest(
    url=url,
    formdata=post_data,
    errback=self.err,
    callback = self.parse,
    cookies = cookies,
    cb_kwargs = {'id':'shixian','page':str(page)},
    )
```

普通请求用scrapy.Request即可。


## Selenium

爬久了总会爆内存，不知道内存泄露的bug有没有修复。以下用的是chrome浏览器，需要预先下载下[驱动](https://chromedriver.chromium.org/downloads)

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from pathlib import Path
import time
import json
import ast 
import re
import os
import yaml
import shutil

options = webdriver.ChromeOptions()
# options.add_argument('--headless')
# https://chromedriver.chromium.org/downloads
s = Service('S:/chromedriver.exe')
options.add_experimental_option('excludeSwitches', ['enable-logging'])
driver = webdriver.Chrome(service=s,options=options)
driver.get('http://www.baidu.com')
time.sleep(1)

def get_current_and_final_page_of_one_book():
    cur = -1
    final = -1
    try:
        pages = driver.find_elements(By.XPATH,'//ul[@class="t-pager"]/li')
    except:
        print('Current page is not found')
        return cur,final
   
    for page in pages:
        if 'active' in page.get_attribute('class'):
            cur = int(page.text)
        if 'number' in page.get_attribute('class'):
            final = int(page.text)
    return cur,final

def download_one_page_of_a_book(skip,config):
    """一页所有文档全部下载成功则返回True,OK
    """
    global CURRENT_PAGE
    global CURRENT_TITLE
    titles = driver.find_elements(By.XPATH,'//div[@class="container"]/div[1]/div[2]/div[2]/table/tbody/tr/td[1]')
    icons = driver.find_elements(By.XPATH,'//div[@class="container"]/div[1]/div[2]/div[2]/table/tbody/tr/td[4]')
    jscode = 'document.location = '+'"'+config['url']+'"'
    driver.execute_script(jscode)
    for title,svgs in zip(titles,icons):
        svgs = svgs.find_elements(By.XPATH,'.//*[name()="svg"]')
        print(f'Current title: {title.text}, skip: {skip}, CURRENT_TITLE: {CURRENT_TITLE}')
        if CURRENT_TITLE is not None and skip and title.text != CURRENT_TITLE:
            continue
        skip = False
        for svg in svgs:
            # if visible 
            if svg.get_attribute('style') == 'display: inline-block;':
                svg.click()
                time.sleep(7)
                cls = driver.window_handles
                if len(cls) > 1:
                    time.sleep(20)
                ok = archive_file(title.text,config)
                if not ok:
                    print(f'Failed to download {title.text}')
                    while len(cls) > 1:
                        driver.switch_to.window(cls[1])
                        driver.close()
                        driver.switch_to.window(cls[0])
                        cls = driver.window_handles
                    return (False, title.text)
                cls = driver.window_handles
                driver.switch_to.window(cls[0])
    CURRENT_TITLE = None
    CURRENT_PAGE += 1
    return (True, 'OK')

# load yaml
with open(target_yml,'r',encoding='utf8') as f:
    SETTINGS = yaml.load(f,Loader=yaml.FullLoader)
# dump yaml
with open(target_yml,'w',encoding='utf8') as f:
    yaml.dump(SETTINGS,f,allow_unicode=True)

driver.close()
driver.quit()

```

或者设置一个helper程序，反复启动selenium：

```python
import subprocess
import time
import datetime
import sys
cmd = 'python ./main.py'
op = 0
while True:
    if op >= 200:
        print('failed 200 times!')
        break
    p = subprocess.Popen(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)
    print('new round at', datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),f'op = {op}')
    op += 1
    
    time.sleep(30)
    if p.poll() == 0:
        break
    p.wait()

```