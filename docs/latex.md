# latex基础

## 推荐工具

使用[Table Generator](https://www.tablesgenerator.com/#)绘制表格

## 英文latex

```latex
\documentclass[conference,11pt]{IEEEtran}
\IEEEoverridecommandlockouts
% The preceding line is only needed to identify funding in the first footnote. If that is unneeded, please comment it out.
\usepackage{cite}
\usepackage{amsmath,amssymb,amsfonts}
\usepackage{algorithmic}
\usepackage{graphicx}
\usepackage{textcomp}
\usepackage{xcolor}
\usepackage{caption}
\usepackage{url}
\def\UrlBreaks{\do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J
\do\K\do\L\do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V
\do\W\do\X\do\Y\do\Z\do\[\do\\\do\]\do\^\do\_\do\`\do\a\do\b
\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l\do\m\do\n
\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z
\do\.\do\@\do\\\do\/\do\!\do\_\do\|\do\;\do\>\do\]\do\)\do\,
\do\?\do\'\do+\do\=\do\#}
\def\BibTeX{{\rm B\kern-.05em{\sc i\kern-.025em b}\kern-.08em
    T\kern-.1667em\lower.7ex\hbox{E}\kern-.125emX}}
\usepackage{lscape, latexsym, amssymb, algorithmic, multirow}
\usepackage[linesnumbered, vlined, ruled]{algorithm2e}
\usepackage{mathtools, bbm, color}
\usepackage{booktabs}
\usepackage{amsthm,mathrsfs,amsfonts,dsfont}
\usepackage{listings}
\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.95}
\lstdefinestyle{mystyle}{
 % backgroundcolor=\color{backcolour},   
 commentstyle=\color{codegreen},
 keywordstyle=\color{magenta},
 numberstyle=\tiny\color{codegray},
 stringstyle=\color{codepurple},
 % basicstyle=\footnotesize\ttfamily,
 basicstyle=\footnotesize\scriptsize,
 breakatwhitespace=false,         
 breaklines=true,                 
 captionpos=b,                    
 keepspaces=true,
 numbers=left,  %% 行号 
 % numbersep=2pt,                  
 showspaces=false,                
 showstringspaces=false,
 showtabs=false,                  
 tabsize=1,
 xleftmargin=\parindent,
}
\lstset{style=mystyle}
\begin{document}

\title{xxxx}

\author{xxxx}

\maketitle

\begin{abstract}
\end{abstract}


\begin{IEEEkeywords}
xxx,xxx
\end{IEEEkeywords}

\bibliographystyle{IEEEtran}
{
\begingroup
\bibliography{ref}
\endgroup
}

\end{document}

```

## 中文latex

```latex
\documentclass[12pt]{article}

\usepackage{cite} % 引用参考文献
\usepackage{ctex} % 中文支持
\usepackage{times}% 英文使用Times New Roman
\usepackage{url,hyperref} % 超链接
\usepackage{xspace} % 无标点自动空格
\usepackage{graphicx} % 插入图片用
\usepackage{geometry} % 设置页边距
\usepackage{listings} % 插入代码块
\usepackage{color} % 定义颜色，用于控制代码高亮
\usepackage{subcaption} % 画子图
\usepackage{tikz} % 后续画圆圈
\usepackage{multirow} % 表格多行文本
% \usepackage{tabu}
\usepackage{longtable}
\usepackage{float}
\usepackage{tabu}
\usepackage{booktabs} % 画表格

\usepackage[linesnumbered, vlined, ruled]{algorithm2e} % 算法列表

% 使用 ctex 宏包设置中文图题
\renewcommand{\figurename}{图}
\renewcommand{\tablename}{表}

% 设置页边距
\geometry{a4paper,left=2cm,right=2cm,top=2cm,bottom=3cm} 


% 设置字体
\newcommand{\song}{\CJKfamily{song}}    % 宋体
\newcommand{\fs}{\CJKfamily{fs}}             % 仿宋体
\newcommand{\kai}{\CJKfamily{kai}}          % 楷体
\newcommand{\hei}{\CJKfamily{hei}}         % 黑体
\newcommand{\li}{\CJKfamily{li}}               % 隶书

% 设置字号
\newcommand{\yihao}{\fontsize{26pt}{36pt}\selectfont}           % 一号, 1.4 倍行距
\newcommand{\erhao}{\fontsize{22pt}{28pt}\selectfont}          % 二号, 1.25倍行距
\newcommand{\xiaoer}{\fontsize{18pt}{18pt}\selectfont}          % 小二, 单倍行距
\newcommand{\sanhao}{\fontsize{16pt}{24pt}\selectfont}        % 三号, 1.5倍行距
\newcommand{\xiaosan}{\fontsize{15pt}{22pt}\selectfont}        % 小三, 1.5倍行距
\newcommand{\sihao}{\fontsize{14pt}{21pt}\selectfont}            % 四号, 1.5 倍行距
\newcommand{\banxiaosi}{\fontsize{13pt}{19.5pt}\selectfont}    % 半小四, 1.5倍行距
\newcommand{\xiaosi}{\fontsize{12pt}{18pt}\selectfont}            % 小四, 1.5倍行距
\newcommand{\dawuhao}{\fontsize{11pt}{11pt}\selectfont}       % 大五号, 单倍行距
\newcommand{\wuhao}{\fontsize{10.5pt}{15.75pt}\selectfont}    % 五号, 单倍行距

% 定义代码样式
\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.95}
\lstdefinestyle{mystyle}{
 % backgroundcolor=\color{backcolour},   
 commentstyle=\color{codegreen},
 keywordstyle=\color{magenta},
 numberstyle=\tiny\color{codegray},
 stringstyle=\color{codepurple},
 % basicstyle=\footnotesize\ttfamily,
 basicstyle=\footnotesize\scriptsize,
 breakatwhitespace=false,         
 breaklines=true,                 
 captionpos=b,                    
 keepspaces=true,
 numbers=left,  %% 行号 
 % numbersep=2pt,                  
 showspaces=false,                
 showstringspaces=false,
 showtabs=false,                  
 tabsize=1,
 xleftmargin=\parindent,
}
\lstset{style=mystyle}

\renewcommand{\abstractname}{\textbf{摘\quad 要}} % 更改摘要二字的样式

% use these commands to consistently refer to stuff

\newcommand{\bugCount}{xx}  

\newcommand{\tabincell}[2]{\begin{tabular}{@{}#1@{}}#2\end{tabular}}

\newcommand*\emptcirc[1][1ex]{\tikz\draw (0,0) circle (#1);} 
\newcommand*\halfcirc[1][1ex]{%
	\begin{tikzpicture}
	\draw[fill] (0,0)-- (90:#1) arc (90:270:#1) -- cycle ;
	\draw (0,0) circle (#1);
	\end{tikzpicture}}
\newcommand*\fullcirc[1][1ex]{\tikz\fill (0,0) circle (#1);} 

\def\BibTeX{{\rm B\kern-.05em{\sc i\kern-.025em b}\kern-.08em
    T\kern-.1667em\lower.7ex\hbox{E}\kern-.125emX}}

\title{\fontsize{18pt}{27pt}\selectfont \textbf{xxxx}}
\author{\fontsize{14pt}{21pt}\selectfont \textbf{xxxx}}
\date{}

\begin{document}
\begin{sloppypar} % 防止长单词出界
\maketitle

\begin{abstract}
\end{abstract}

\section{背景}

\subsection{可信执行环境}
\bibliographystyle{plain}
\bibliography{Ref}

\end{sloppypar}
\end{document}
```