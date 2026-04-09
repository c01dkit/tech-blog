# 栈

栈（stack）是一种只允许在一端进行插入和删除的线性结构，这一端称为栈顶（top），另一端称为栈底。栈最鲜明的特性是「后进先出」（LIFO, Last In First Out）——最后压入的元素最先被弹出。

形象地说，栈就像一摞盘子：放盘子只能放在最上面，取盘子也只能从最上面取。这种受限的访问方式看似不灵活，却非常契合一类问题：凡是涉及「回退」「嵌套」「对称」的场景，栈几乎都是首选的数据结构。

## 核心操作

| 操作 | 说明 | 复杂度 |
|---|---|---|
| `push(x)` | 压入元素 `x` | $O(1)$ |
| `pop()` | 弹出栈顶并返回 | $O(1)$ |
| `top()` / `peek()` | 查看栈顶而不弹出 | $O(1)$ |
| `empty()` | 判空 | $O(1)$ |
| `size()` | 元素个数 | $O(1)$ |

栈的所有基本操作都是常数时间，这让它在实现其他算法时几乎不产生额外的渐进开销。

## 两种实现方式

### 基于数组

用一个动态数组加一个指针 `top`（指向下一个可写位置）即可：

```cpp
template <typename T, size_t N>
class ArrayStack {
    T data[N];
    int top_ = 0;
public:
    void push(const T& x) {
        if (top_ >= (int)N) throw std::overflow_error("stack overflow");
        data[top_++] = x;
    }
    T pop() {
        if (top_ == 0) throw std::underflow_error("stack underflow");
        return data[--top_];
    }
    const T& top() const { return data[top_ - 1]; }
    bool empty() const { return top_ == 0; }
    int size() const { return top_; }
};
```

优点是常数小、cache 友好；缺点是必须指定最大容量（或者退化成动态数组带来均摊扩容开销）。

### 基于链表

用一条单向链表，把头节点当成栈顶：

```cpp
template <typename T>
class ListStack {
    struct Node { T val; Node* next; };
    Node* head = nullptr;
    int sz = 0;
public:
    void push(const T& x) { head = new Node{x, head}; ++sz; }
    T pop() {
        Node* n = head;
        T v = n->val;
        head = head->next;
        delete n;
        --sz;
        return v;
    }
    ~ListStack() { while (head) pop(); }
};
```

优点是容量动态无上限；缺点是每个元素都要多一个指针、不连续存储、分配开销大。

## 典型应用

### 括号匹配

判定 `({[]})` 是否是合法括号序列，正是栈最经典的用例：

```cpp
bool is_valid(const string& s) {
    stack<char> st;
    for (char c : s) {
        if (c == '(' || c == '[' || c == '{') st.push(c);
        else {
            if (st.empty()) return false;
            char t = st.top(); st.pop();
            if ((c == ')' && t != '(') ||
                (c == ']' && t != '[') ||
                (c == '}' && t != '{')) return false;
        }
    }
    return st.empty();
}
```

### 中缀表达式转后缀（调度场算法）

后缀表达式（逆波兰式）对计算机求值非常友好，只需要一个栈就能完成。将 `3 + 4 * 2` 转成 `3 4 2 * +` 的过程，核心思路是遇到运算符时根据优先级决定弹栈还是入栈：

```text
遍历中缀：
  操作数：直接输出
  左括号：入栈
  右括号：弹栈直到遇到左括号
  运算符：弹出栈顶所有优先级 >= 当前运算符的，再把自己入栈
遍历结束：把栈里剩下的运算符依次弹出
```

### 单调栈

单调栈是一种维持栈内元素按某种单调性的技巧，能把一些「下一个更大元素」「柱状图最大矩形」之类的问题从 $O(n^2)$ 降到 $O(n)$。

求数组中每个位置右侧第一个更大的元素：

```cpp
vector<int> next_greater(const vector<int>& a) {
    int n = a.size();
    vector<int> ans(n, -1);
    stack<int> st;     // 栈内存下标，对应的值单调递减
    for (int i = 0; i < n; ++i) {
        while (!st.empty() && a[st.top()] < a[i]) {
            ans[st.top()] = a[i];
            st.pop();
        }
        st.push(i);
    }
    return ans;
}
```

每个元素最多入栈一次、出栈一次，总复杂度 $O(n)$。

### 函数调用栈

操作系统为每个线程维护一条调用栈，函数每被调用一次就压入一帧（frame），包含参数、返回地址、局部变量；函数返回时栈帧被销毁。这是 CPU 层面对栈结构最广泛的应用——如果栈没有了，递归就无从谈起。

无限递归导致的 `stack overflow`，本质就是程序持续 push 栈帧、却从不 pop，最终超出系统给线程预留的栈空间上限。

## 栈 vs 其他结构

| | 访问模式 | 代表用途 |
|---|---|---|
| 栈 | LIFO | 括号匹配、回溯、表达式求值 |
| 队列 | FIFO | BFS、消息管道 |
| 双端队列 | 两端均可 | 滑动窗口、单调队列 |
