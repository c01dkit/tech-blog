# 链表

链表（linked list）是由一组离散分布的节点通过指针串联而成的线性结构。与数组最大的区别在于：链表的元素**不要求在物理地址上连续**，而是每个节点自行携带指向下一个节点的指针。这种组织方式牺牲了随机访问的 $O(1)$ 能力，换来了在任意位置 $O(1)$ 插入、删除的灵活性。

## 常见变体

| 变体 | 特征 |
|---|---|
| 单链表 | 每个节点只有 `next` 指针 |
| 双向链表 | 每个节点同时有 `prev` 和 `next`，双向可走 |
| 循环链表 | 尾节点的 `next` 指回头节点，形成环 |
| 带哨兵的链表 | 头尾各放一个不存数据的 dummy 节点，简化边界处理 |

工程实现里双向 + 哨兵的组合最常见——Linux 内核的 `list_head`、C++ `std::list` 都是这个形态。

## 单链表基础

```cpp
struct Node {
    int val;
    Node* next;
};

// 头插：O(1)
Node* push_front(Node* head, int x) {
    return new Node{x, head};
}

// 在 prev 节点后插入：O(1)
void insert_after(Node* prev, int x) {
    prev->next = new Node{x, prev->next};
}

// 删除 prev 之后的节点：O(1)
void erase_after(Node* prev) {
    Node* n = prev->next;
    if (!n) return;
    prev->next = n->next;
    delete n;
}

// 按值查找：O(n)
Node* find(Node* head, int x) {
    for (Node* p = head; p; p = p->next)
        if (p->val == x) return p;
    return nullptr;
}
```

注意上面所有「$O(1)$」的前提都是：已经拿到了操作点的前驱节点指针。如果只给了值或下标，那么要先花 $O(n)$ 找到前驱，再做插入/删除。

## 哨兵：告别边界讨论

单链表代码最烦人的地方是头节点——插入或删除发生在头节点时，`head` 本身要变，这和其他位置的逻辑不一样，导致分支爆炸。一个几乎是银弹的技巧是加一个**哨兵节点（dummy node）**：

```cpp
Node dummy{0, head};
// 之后所有操作都从 dummy 出发，head 被统一成「第一个数据节点」
// 操作完毕后真正的 head 就是 dummy.next
```

这样一来，对头节点的操作就和中间节点完全一致，代码行数通常能减半。

## 双向链表

```cpp
struct DNode {
    int val;
    DNode* prev;
    DNode* next;
};

// 在 p 之前插入 x
void insert_before(DNode* p, int x) {
    DNode* n = new DNode{x, p->prev, p};
    p->prev->next = n;
    p->prev = n;
}

// 删除 p
void erase(DNode* p) {
    p->prev->next = p->next;
    p->next->prev = p->prev;
    delete p;
}
```

双向链表的核心好处是：**给定任意一个节点指针就能在 $O(1)$ 时间把它从链中移除**，不需要先走到前驱。这是 LRU 缓存等结构的关键——哈希表记住某个 key 对应的节点指针，要淘汰或提升时直接 $O(1)$ 完成。

## 经典算法

### 反转单链表

迭代写法：

```cpp
Node* reverse(Node* head) {
    Node* prev = nullptr;
    while (head) {
        Node* next = head->next;
        head->next = prev;
        prev = head;
        head = next;
    }
    return prev;
}
```

递归写法：

```cpp
Node* reverse(Node* head) {
    if (!head || !head->next) return head;
    Node* new_head = reverse(head->next);
    head->next->next = head;
    head->next = nullptr;
    return new_head;
}
```

### 快慢指针

快慢指针是链表上使用最广的技巧之一。快指针每步走两格，慢指针每步走一格，能解决一大批问题：

**求中点**：快指针走到末尾时，慢指针恰好在中点。

```cpp
Node* middle(Node* head) {
    Node *slow = head, *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
    }
    return slow;
}
```

**判环（Floyd 判圈算法）**：如果链表有环，快慢指针必定在环内相遇；如果没环，快指针会走到 `nullptr`。

```cpp
bool has_cycle(Node* head) {
    Node *slow = head, *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) return true;
    }
    return false;
}
```

**找环的入口**：相遇之后，把其中一个指针放回头，两者每次各走一步，再次相遇的位置就是环入口。证明用到了简单的代数推导，可以自行补齐。

### 归并两条有序链表

```cpp
Node* merge(Node* a, Node* b) {
    Node dummy{0, nullptr};
    Node* tail = &dummy;
    while (a && b) {
        if (a->val <= b->val) { tail->next = a; a = a->next; }
        else                  { tail->next = b; b = b->next; }
        tail = tail->next;
    }
    tail->next = a ? a : b;
    return dummy.next;
}
```

结合分治可以在 $O(n\log n)$ 时间完成链表归并排序，且空间复杂度只有 $O(\log n)$（递归栈），是链表上为数不多能做到 $O(n\log n)$ 排序的方式。

## 链表 vs 数组

工程中什么时候该用链表？一个常见的误解是「频繁插入删除就用链表」——事实上这个经验在现代计算机体系结构下并不总成立。由于 cache 预取，数组的顺序访问性能通常远胜链表；就连「中间插入」这件事，对于中等规模的数据（几千个元素以内），数组做内存搬移的总耗时可能还比链表一次次 `new` 更快。

链表真正有优势的场景是：

- 元素**不需要随机访问**，只按顺序遍历；
- 有指向节点的外部指针，需要 $O(1)$ 直接摘除（典型如 LRU、内核的进程链）；
- 数据规模大、动态频繁，且不希望一次扩容拷贝大量数据。
