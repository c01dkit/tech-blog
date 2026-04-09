# 数组

数组（array）是最基础也最容易被低估的数据结构。它的核心特点只有一句话：**在内存中占据一段连续的存储空间，所有元素大小相同**。正是这两个约束决定了数组所有的优缺点。

## 为什么随机访问是 $O(1)$

既然元素大小相同，且起始地址固定，那么第 $i$ 个元素的地址就可以由一次简单的乘加算出：

$$
\text{addr}(a[i]) = \text{addr}(a[0]) + i \cdot \text{sizeof}(\text{element})
$$

这一步只需常数时间，与 $i$ 多大无关——这就是所谓的「随机访问 $O(1)$」。如果把元素换成大小不定的变长结构，地址计算就退化成必须从头扫一遍，复杂度变成 $O(n)$。

## 静态数组 vs 动态数组

C 风格的数组 `int a[100]`、C++ 的 `std::array` 属于**静态数组**：长度在编译期或初始化时就定死，之后不可变更。好处是没有任何运行时额外开销，坏处是必须事先估好容量。

动态数组（`std::vector`、Java `ArrayList`、Python `list`、Go `slice`）则在底层再包一层：维护 `{ 指针, size, capacity }` 三元组。当 `size == capacity` 时触发扩容，一般按 1.5 或 2 倍放大，申请更大一段内存，把旧元素拷过去，再释放旧内存。

```cpp
// 一个最小可用的动态数组实现
template <typename T>
class Vector {
    T* data_ = nullptr;
    size_t size_ = 0;
    size_t cap_ = 0;
public:
    void push_back(const T& x) {
        if (size_ == cap_) {
            size_t new_cap = cap_ == 0 ? 4 : cap_ * 2;
            T* new_data = new T[new_cap];
            for (size_t i = 0; i < size_; ++i) new_data[i] = data_[i];
            delete[] data_;
            data_ = new_data;
            cap_ = new_cap;
        }
        data_[size_++] = x;
    }
    T& operator[](size_t i) { return data_[i]; }
    size_t size() const { return size_; }
    ~Vector() { delete[] data_; }
};
```

`push_back` 的均摊复杂度是 $O(1)$。直观理解：假设当前容量是 $n$，那么要触发下一次扩容必须再 push $n$ 次，而这次扩容的代价是 $O(n)$。把这 $O(n)$ 的代价摊到这 $n$ 次 push 上，平均每次 $O(1)$。

## 核心操作及复杂度

| 操作 | 复杂度 | 备注 |
|---|---|---|
| `a[i]` 访问 | $O(1)$ | 地址算术 |
| 末尾追加 | 均摊 $O(1)$ | 可能触发扩容 |
| 末尾删除 | $O(1)$ | 只需 `size--` |
| 中间插入 | $O(n)$ | 后续元素都要右移 |
| 中间删除 | $O(n)$ | 后续元素都要左移 |
| 顺序查找 | $O(n)$ | 无序情况下 |
| 二分查找 | $O(\log n)$ | 仅限已排序数组 |

## 二分查找

二分查找是数组上最常用的算法之一，思路简单但边界极易写错。下面给出左闭右闭区间的标准写法：

```cpp
int lower_bound(const vector<int>& a, int target) {
    int l = 0, r = a.size();   // 左闭右开 [l, r)
    while (l < r) {
        int mid = l + (r - l) / 2;
        if (a[mid] < target) l = mid + 1;
        else                  r = mid;
    }
    return l;   // 第一个 >= target 的位置
}
```

两个容易踩的坑：

1. **`mid = (l + r) / 2` 在极端情况下会溢出**。`l + r` 可能超过 `INT_MAX`，应当写成 `l + (r - l) / 2`。
2. **循环不变量要一致**。如果选了左闭右开 `[l, r)`，那么 `r` 初始化为 `n`、循环条件是 `l < r`、收缩时 `r = mid`。如果选了左闭右闭 `[l, r]`，那么 `r = n - 1`、`l <= r`、收缩 `r = mid - 1`。两套写法不能混用。

## 常见技巧

### 前缀和

预处理一遍前缀和 $S_i = \sum_{k=0}^{i-1} a_k$，就能在 $O(1)$ 时间内查询任意区间和 $\sum_{k=l}^{r-1} a_k = S_r - S_l$。二维前缀和类似，可以 $O(1)$ 查子矩阵和。

### 双指针 / 滑动窗口

数组上大量问题都可以用双指针把 $O(n^2)$ 压到 $O(n)$。典型如「最长无重复子串」：右指针不断扩张，左指针在遇到重复时右移，每个元素至多被两个指针各访问一次。

### 差分数组

如果要对区间 $[l, r]$ 整体加 $v$ 做多次修改，单次修改 $O(n)$ 难以接受。差分数组 $d_i = a_i - a_{i-1}$ 把区间加转换成两次单点修改：`d[l] += v; d[r+1] -= v;`。最后再求一次前缀和还原 $a$，总复杂度 $O(n + m)$。

## 缓存友好性

数组常常被和链表拿来做比较。即使在理论复杂度相当的场景下，数组由于连续存储，CPU cache 预取机制可以一次性把相邻元素加载进来，顺序遍历速度比链表快几个数量级。这也是工程中大量数据结构（如 `std::deque`、`HashMap` 的桶）依然偏向数组化存储的原因。
