# autoconf学习笔记

自己开发软件时，生成规范的configure等文件。可参考[https://www.cnblogs.com/klausage/p/14163844.html](https://www.cnblogs.com/klausage/p/14163844.html)等


## 不分目录结构

**编写Makefile.am文件，比如：**

```makefile
bin_PROGRAMS=helloworld
helloworld_SOURCES=helloworld.c
```

* `bin_PROGRAMS`用于给项目起名，比如X，那么之后的X_SOURCES则用来指定使用的源文件


**执行`autoscan`，生成configure.scan，并修改其中的AC_INIT、AM_INIT_AUTOMAKE，重命名文件为configure.ac，比如：**

```makefile
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AM_INIT_AUTOMAKE([foreign]) # 如果不加这一句，默认gnu，则之后目录里要有NEWS、README、AUTHORS、ChangLog等文件（需自己手动建立）
AC_CONFIG_SRCDIR([main.h])
AC_CONFIG_HEADERS([config.h])
# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

```

**执行`aclocal && autoheader && autoconf`，生成aclocal.m4、config.h.in和configure**

**运行`automake --add-missing`，会根据Makefile.am生成Makefile.in**

**运行`./configure`生成makefile**

**运行`make`，基于makefile编译代码**

## 区分目录结构

也就是说源码可能在多个文件夹下，比如src。那么每个文件夹需要单独写Makefile.am来指定如何编译。

**编写Makefile.am文件**

源码所在的文件夹的Makefile文件示例：

```makefile
bin_PROGRAMS = reverse

#AM_CFLAGS= -DDEBUG -DLOG_INSTRUCTIONS -I ../include
AM_CFLAGS= -DDEBUG -I ../include

reverse_CPPFLAGS = -msse4.1

# 使用LDFLAG会在gcc中部放-l，导致找不到第三方库。用LDADD可以添加到整个gcc指令的最后
reverse_LDADD = -lcapstone

handlers_FILES = handler_flag_manip.c handler_interrupt.c

#handler_interrupt.c

reverse_SOURCES = access_memory.c alias_manager.c $(handlers_FILES)

```

* `AM_CFLAGS`用于添加编译选项

项目文件夹需要指定源文件所在的文件夹

POMP的例子：

```makefile
SUBDIRS=src # 指定src文件夹
dist_doc_DATA=README

TESTSUITES_DIR = testsuites
EXECUTABLE=$(SUBDIRS)/reverse

abc2mtex:
	$(EXECUTABLE) $(TESTSUITES_DIR)/$@/core $(TESTSUITES_DIR)/library/ $(TESTSUITES_DIR)/$@/inst.reverse

aireplay-ng:
	$(EXECUTABLE) $(TESTSUITES_DIR)/$@/core $(TESTSUITES_DIR)/library/ $(TESTSUITES_DIR)/$@/inst.reverse


```

**执行`autoscan`，生成configure.scan，并修改其中的AC_INIT、AM_INIT_AUTOMAKE，重命名文件为configure.ac，比如：**

```makefile
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([reverse_from_coredump], [0.0.1], [mudongliangabcd@gmail.com])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
AC_CHECK_LIB([disasm], [x86_init])
AC_CHECK_LIB([elf], [gelf_getehdr])

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h malloc.h stddef.h stdint.h stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_OFF_T
AC_TYPE_SIZE_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([memset strerror])

AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT

```


**执行`aclocal && autoheader && autoconf`，生成aclocal.m4、config.h.in和configure**

**运行`automake --add-missing`，会根据Makefile.am生成Makefile.in**

**运行`./configure`生成makefile**

**运行`make`，基于makefile编译代码**