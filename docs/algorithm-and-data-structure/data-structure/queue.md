# 队列

队列（queue）是另一种受限的线性结构：插入只能在一端（队尾，tail/rear），删除只能在另一端（队首，head/front）。与栈的 LIFO 相对，队列的访问特性是「先进先出」（FIFO, First In First Out）——最早进入的元素最先被取出，像排队买票一样讲求秩序。

## 核心操作

| 操作 | 说明 | 复杂度 |
|---|---|---|
| `enqueue(x)` / `push` | 从队尾插入元素 | $O(1)$ |
| `dequeue()` / `pop` | 从队首取出元素 | $O(1)$ |
| `front()` | 查看队首 | $O(1)$ |
| `back()` | 查看队尾 | $O(1)$ |
| `empty()` | 判空 | $O(1)$ |

## 循环队列：为什么需要「环」

最朴素的数组实现——头指针 `head`、尾指针 `tail`——会遇到一个尴尬的问题：反复入队出队以后，`head` 和 `tail` 都会一路向右走，数组前面的空间明明空着，却没法再用。解决办法是让指针在数组上「绕圈」，即循环队列（circular queue）：

```cpp
template <typename T, size_t N>
class CircularQueue {
    T data[N];
    int head = 0, tail = 0, cnt = 0;
public:
    bool push(const T& x) {
        if (cnt == (int)N) return false;        // 满
        data[tail] = x;
        tail = (tail + 1) % N;
        ++cnt;
        return true;
    }
    bool pop(T& out) {
        if (cnt == 0) return false;             // 空
        out = data[head];
        head = (head + 1) % N;
        --cnt;
        return true;
    }
    bool empty() const { return cnt == 0; }
    bool full()  const { return cnt == (int)N; }
};
```

要点：

- 用额外的 `cnt` 计数避免「空和满指针相等」的二义性。另一种常见写法是牺牲一个位置，即 `tail == (head - 1 + N) % N` 代表满。
- `head`、`tail` 更新时都要 `% N`。

## 基于链表的实现

同时维护 `head` 和 `tail` 指针的单链表也能胜任队列，并且没有容量上限：

```cpp
template <typename T>
class LinkedQueue {
    struct Node { T val; Node* next; };
    Node *head = nullptr, *tail = nullptr;
public:
    void push(const T& x) {
        Node* n = new Node{x, nullptr};
        if (!tail) head = tail = n;
        else { tail->next = n; tail = n; }
    }
    T pop() {
        Node* n = head;
        T v = n->val;
        head = n->next;
        if (!head) tail = nullptr;
        delete n;
        return v;
    }
    bool empty() const { return head == nullptr; }
};
```

相比循环数组，链表实现胜在弹性，劣在每次操作都要 `new/delete`，常数大，缓存不友好。

## 双端队列 deque

如果允许两端都能插入和删除，队列就推广为双端队列（deque, double-ended queue）。C++ 的 `std::deque` 底层是分段连续的「块数组」，在两端插入/删除均摊 $O(1)$，随机访问也是 $O(1)$（但常数比 vector 略大）。

双端队列最经典的用法是**单调队列**，用来解决滑动窗口最值问题：

```cpp
// 求每个长度为 k 的滑动窗口的最大值
vector<int> sliding_max(const vector<int>& a, int k) {
    deque<int> dq;    // 存下标，对应的值从队首到队尾单调递减
    vector<int> ans;
    for (int i = 0; i < (int)a.size(); ++i) {
        while (!dq.empty() && dq.front() <= i - k) dq.pop_front();
        while (!dq.empty() && a[dq.back()] <= a[i]) dq.pop_back();
        dq.push_back(i);
        if (i >= k - 1) ans.push_back(a[dq.front()]);
    }
    return ans;
}
```

核心思想：队尾维护单调性，淘汰「既比新元素小，又比新元素早过期」的老元素；队首在过期时淘汰。每个元素至多入队一次、出队一次，总复杂度 $O(n)$。

## 优先队列

优先队列（priority queue）名字里有「队列」，但它**不是**严格意义上的 FIFO。它的取出顺序由元素的优先级决定，最高（或最低）优先级的元素先出队。常用二叉堆实现，`push` 和 `pop` 均为 $O(\log n)$，`top` 为 $O(1)$。详见 [树](tree.md) 一节对堆的介绍。

## 典型应用

**广度优先搜索（BFS）**：图或树的 BFS 以队列作为核心数据结构，保证先访问的层先被扩展，天然得到最短路径。

**任务调度**：操作系统的就绪队列、消息中间件（RabbitMQ、Kafka、Redis Stream）都以队列作为抽象，把生产者和消费者解耦。

**缓冲区**：I/O 场景下，生产者写入的速率和消费者读取的速率常常不匹配，在中间放一个循环队列做缓冲，可以吸收突发流量。

**打印队列 / 请求队列**：同一时刻可能有多个任务请求同一资源，按先到先服务（FCFS）的顺序排队是一种简单公平的策略。
