# 树

树（tree）是一类典型的非线性结构：它由若干节点构成，存在一个特殊节点叫做**根**，其余节点被划分成若干互不相交的子集，每个子集本身又是一棵树（递归定义）。非根节点都有且仅有一个父节点，因此树等价于「没有回路的连通无向图」。

## 基本术语

- **根（root）**：没有父节点的那个节点。
- **叶子（leaf）**：没有子节点的节点。
- **度（degree）**：一个节点拥有的子节点数。
- **深度（depth）**：从根到该节点路径上的边数。
- **高度（height）**：从该节点到其子树中最远叶子的边数。整棵树的高度即根的高度。
- **层（level）**：根为第 0 层，其子节点为第 1 层，以此类推。

## 二叉树

每个节点至多有两个子节点（分别称为左孩子、右孩子）的树。二叉树是最常用、最基础的树形结构。

```cpp
struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int v): val(v), left(nullptr), right(nullptr) {}
};
```

几种特殊形态：

- **满二叉树**：每一层都被填满，即第 $k$ 层有 $2^k$ 个节点。高度为 $h$ 的满二叉树共 $2^{h+1} - 1$ 个节点。
- **完全二叉树**：除最后一层外每层都满，且最后一层的节点从左向右紧密排列。堆就依赖这个性质用数组直接存储。
- **平衡二叉树**：任意节点左右子树高度差不超过 1。典型实现是 AVL 树、红黑树。

## 遍历

二叉树有四种主流遍历方式，前三种都是深度优先，区别只在访问根节点的时机：

| 遍历方式 | 顺序 |
|---|---|
| 前序（pre-order） | 根 → 左 → 右 |
| 中序（in-order）  | 左 → 根 → 右 |
| 后序（post-order）| 左 → 右 → 根 |
| 层序（level-order）| 按层从上到下、每层从左到右 |

递归实现非常直观：

```cpp
void inorder(TreeNode* root) {
    if (!root) return;
    inorder(root->left);
    cout << root->val << " ";
    inorder(root->right);
}
```

用显式栈把递归展开成迭代是面试里常考的变体：

```cpp
void inorder_iter(TreeNode* root) {
    stack<TreeNode*> st;
    TreeNode* p = root;
    while (p || !st.empty()) {
        while (p) { st.push(p); p = p->left; }
        p = st.top(); st.pop();
        cout << p->val << " ";
        p = p->right;
    }
}
```

层序遍历本质上是用队列实现的 BFS：

```cpp
void level_order(TreeNode* root) {
    if (!root) return;
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        TreeNode* t = q.front(); q.pop();
        cout << t->val << " ";
        if (t->left)  q.push(t->left);
        if (t->right) q.push(t->right);
    }
}
```

## 二叉搜索树（BST）

二叉搜索树是一种带排序语义的二叉树，对任意节点 `n`，都满足：

- 左子树所有节点的值 $<$ `n.val`
- 右子树所有节点的值 $>$ `n.val`

这个性质保证了**中序遍历的结果是一个有序序列**。BST 支持 $O(h)$ 的查找、插入、删除，其中 $h$ 是树的高度。理想情况下 $h = O(\log n)$，但如果按顺序插入有序数据，BST 会退化成一条链，$h = O(n)$，这也是为什么需要自平衡的 BST。

```cpp
TreeNode* find(TreeNode* root, int x) {
    while (root) {
        if (x == root->val) return root;
        root = x < root->val ? root->left : root->right;
    }
    return nullptr;
}

TreeNode* insert(TreeNode* root, int x) {
    if (!root) return new TreeNode(x);
    if (x < root->val) root->left  = insert(root->left, x);
    else if (x > root->val) root->right = insert(root->right, x);
    return root;
}
```

BST 的删除要分三种情况：无子、一个子、两个子。两个子时的经典做法是用右子树的最小节点（或左子树的最大节点）顶替被删节点的位置。

## 自平衡 BST：AVL 与红黑树

**AVL 树**：每次插入/删除后检查所有祖先节点，若发现某节点左右子树高度差超过 1，就通过左旋、右旋（或左右旋、右左旋组合）恢复平衡。AVL 对高度要求严格，查询最快，但维护成本略高。

**红黑树**：放宽平衡约束——只要求最长路径不超过最短路径的两倍。通过给节点染色并满足五条规则保证这一点。插入、删除时的旋转次数更少，常数上比 AVL 更友好，是 `std::map`、`std::set`、Linux 内核 `rbtree`、Java `TreeMap` 的底层结构。

两者的所有操作都是严格的 $O(\log n)$。

## 堆与优先队列

堆是一棵**完全二叉树**，且满足堆序性：以大根堆为例，任意父节点的值都大于等于它的子节点。由于是完全二叉树，可以直接用数组连续存储，节点 $i$ 的左右孩子在 $2i+1$、$2i+2$，父亲在 $(i-1)/2$——不需要任何指针。

```cpp
class MaxHeap {
    vector<int> a;
    void up(int i) {
        while (i > 0) {
            int p = (i - 1) / 2;
            if (a[p] >= a[i]) break;
            swap(a[p], a[i]);
            i = p;
        }
    }
    void down(int i) {
        int n = a.size();
        while (true) {
            int l = 2*i + 1, r = 2*i + 2, big = i;
            if (l < n && a[l] > a[big]) big = l;
            if (r < n && a[r] > a[big]) big = r;
            if (big == i) break;
            swap(a[big], a[i]);
            i = big;
        }
    }
public:
    void push(int x) { a.push_back(x); up(a.size() - 1); }
    int  top() const { return a.front(); }
    void pop() { a.front() = a.back(); a.pop_back(); if (!a.empty()) down(0); }
    int  size() const { return a.size(); }
};
```

堆的 `push`、`pop` 均为 $O(\log n)$，`top` 为 $O(1)$，是优先队列最常见的底层实现。Top-K、定时器、Dijkstra 最短路等都大量使用它。

## Trie（字典树）

Trie 是一种专门处理字符串集合的树：每条从根到节点的路径代表一个字符串前缀。典型的用途是前缀查询、自动补全、敏感词过滤。

```cpp
struct Trie {
    Trie* child[26] = {};
    bool end = false;

    void insert(const string& s) {
        Trie* p = this;
        for (char c : s) {
            int i = c - 'a';
            if (!p->child[i]) p->child[i] = new Trie;
            p = p->child[i];
        }
        p->end = true;
    }

    bool contains(const string& s) const {
        const Trie* p = this;
        for (char c : s) {
            int i = c - 'a';
            if (!p->child[i]) return false;
            p = p->child[i];
        }
        return p->end;
    }
};
```

插入和查询的复杂度都是 $O(L)$，其中 $L$ 是字符串长度，和字典中词数无关。Trie 的缺点是指针开销大，实际工程中常用压缩变体，如双数组 Trie、AC 自动机。

## 其他树形结构

- **线段树**：处理区间查询与区间修改，支持懒惰标记，单次操作 $O(\log n)$。
- **树状数组（BIT/Fenwick tree）**：功能比线段树弱，但代码极短，常数极小，适合前缀和的动态维护。
- **B 树 / B+ 树**：多路平衡搜索树，节点可容纳数十到数千个键，专为磁盘和文件系统设计。MySQL InnoDB 的索引就是 B+ 树。
- **并查集**：用以森林表达不相交集合，配合路径压缩与按秩合并，近乎 $O(1)$ 均摊处理「合并」和「查询连通分量」。
