# Python

## 获取未知对象的所有属性

obj.\_\_dir\_\_() 或者dir(obj)


* 解析命令行参数：argparse
* 日志输出：logging
* 解析yml配置文件：yaml
* python调用C库：ctypes.cdll.LoadLibrary
* 设定计时信号：signal.alarm


## 参数解析：argparse

根据用户传参而执行不同的功能，又分多个层次。比如pip3命令，可以有pip3 install和pip3 freeze等等，对于每一个子解析又有进一步的参数，比如pip3 install --upgrade, pip3 install --force-reinstall等等。

```python

import argparse

def populate_parser(parser):
    parser.add_argument('input_file', type=str, help="Path to the file containing the mutated input to load")
    parser.add_argument('--prefix-input', dest='prefix_input_path', type=str, help="(Optional) Path to the file containing a constant input to load")
    parser.add_argument('-c', '--config', default="config.yml", help="The emulator configuration to use. Defaults to 'config.yml'")

    # Verbosity switches
    parser.add_argument('-v', '--print-exit-info', default=False, action="store_true", help="Print some information about the exit reason.")
    parser.add_argument('-t', '--trace-funcs', dest='trace_funcs', default=False, action='store_true')
parser = argparse.ArgumentParser(description="Fuzzware")
subparsers = parser.add_subparsers(title="Fuzzware Components", help='Fuzzware utilities:', description="Fuzzware supports its different functions using a set of utilities.\n\nUse 'fuzzware <util_name> -h' for more details.")
parser_pipeline = subparsers.add_parser(MODE_PIPELINE, help="Running the full pipeline. Fuzzware's main utility.")
parser_pipeline.set_defaults(func=do_pipeline)
# Pipeline command-line arguments
parser_pipeline.add_argument('target_dir', nargs="?", type=os.path.abspath, default=os.curdir, help="Directory containing the main config. Defaults to the current working dir.")


parser = argparse.ArgumentParser(description="Fuzzware emulation harness")
populate_parser(parser)

```

## 配置读取：yaml

除了argparse以外，可以把一些很长的配置数据（比如多到命令行敲是不现实的）放到yml里，然后用yaml读取，得到（嵌套的）字典，然后再取内容就很方便了。

```python
import yaml

with open('config.yml', 'rb') as f:
    data = yaml.load(f, Loader=yaml.FullLoader)
    print(data)
```

那么data就是一个字典，根据yml里的内容可能成为嵌套关系。字典里为空的值会变成None，true或True或TRUE都会变成True，数字会被识别成整数或浮点数，字符串会被识别成字符串（含空格）

比如下面的yml文件

```yaml
item:
  test1: 1
  test2: 2
  test2.1: TRUE
  test2.2: true
  test2.3: True
matters:
  test3: 3
  3: 333
  test4: 4
  test5: ${item.test1}
  test6: a b c d
  test7: 
```

会被识别为


```python
{'item': {'test1': 1, 'test2': 2, 'test2.1': True, 'test2.2': True, 'test2.3': True}, 'matters': {'test3': 3, 3: 333, 'test4': 4, 'test5': '${item.test1}', 'test6': 'a b c d', 'test7': None}}

```

## 输出日志：logging

在开发程序的时候，遇到bug或者想弄清楚临时结果、控制流走向的时候，采用print的传统方法来打印变量有点过于蠢笨了。而使用logging可以随时打印数据到控制台或文件，可以自定义打印范围，而且易于调试。

```python
import logging

logging.basicConfig(format='[%(levelname)s %(filename)s:%(lineno)d]: %(message)s', stream=sys.stdout, level=logging.DEBUG)
logger = logging.getLogger('TEST')

logger.debug('here is a test!')
logger.info('info level')

```

当然也可以全面了解下logging，推荐阅读[这个知乎专栏](https://zhuanlan.zhihu.com/p/476549020)

```python
import logging

# 1、创建一个logger
logger = logging.getLogger('mylogger')
logger.setLevel(logging.DEBUG)

# 2、创建一个handler，用于写入日志文件
fh = logging.FileHandler('test.log')
fh.setLevel(logging.DEBUG)

# 再创建一个handler，用于输出到控制台
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# 3、定义handler的输出格式（formatter）
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# 4、给handler添加formatter
fh.setFormatter(formatter)
ch.setFormatter(formatter)

# 5、给logger添加handler
logger.addHandler(fh)
logger.addHandler(ch)
```

以及[修改log的颜色](https://www.cnblogs.com/xyztank/articles/13598633.html)(不过没有试过，不知道是否可用)

## 接口设计

一系列相似的函数完成相似的功能（比如不同解析函数解析不同种类的日志，都完成“数据处理”这一功能）时，可以将函数名作为参数传入公共处理函数，设计更清晰。

```python

import re

# 0000 11c4 0
bb_regex = re.compile(r"([0-9a-f]+) ([0-9a-f]+) ([0-9]+)")
def parse_bb_line(line):
    event_id, pc, cnt = bb_regex.match(line).groups()

    event_id = int(event_id, 16)
    pc = int(pc, 16)
    cnt = int(cnt)

    return event_id, pc, cnt

def parse_mmio_set_line(line):
    pc, addr, mode = line.split(" ")
    return (int(pc, 16), int(addr, 16), mode[0])

def _parse_file(filename, line_parser):
    try:
        with open(filename, "r") as f:
            return [line_parser(line) for line in f.readlines() if line]
    except FileNotFoundError:
        return []

def parse_bbl_trace(filename):
    return _parse_file(filename, parse_bb_line)

def parse_mmio_set(filename):
    return _parse_file(filename, parse_mmio_set_line)
```

## 计时终止程序

如果需要让程序在运行一段时间后终止，在程序内部进行时间检查并不优雅（因为是无关逻辑的）；可以为这个子程序设计signal

```python

pipeline = Pipeline(args.target_dir, args.project_name, args.base_inputs, args.num_local_fuzzer_instances, args.disable_modeling, write_worker_logs=not args.silent_workers, do_full_tracing=args.full_traces, config_name=args.runtime_config_name, timeout_seconds=timeout_seconds, use_aflpp=args.aflpp)

try:
    if timeout_seconds != 0:
        def handler(signal_no, stack_frame):
            pipeline.request_shutdown()

        # spin up an alarm for the time
        signal.signal(signal.SIGALRM, handler)
        signal.alarm(timeout_seconds)

    pipeline.start()
except Exception as e:
    logger.error(f"Got exception, shutting down pipeline: {e}")
    import traceback
    traceback.print_exc()
    status = 1

```

## 参考项目

* [(USENIX Security 2022)Fuzzware: Using Precise MMIO Modeling for Effective Firmware Fuzzing](https://github.com/fuzzware-fuzzer/fuzzware)