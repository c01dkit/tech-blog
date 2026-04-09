# 动态规划算法

动态规划（Dynamic Programming, DP）可能是算法课里最让人又爱又恨的一节。爱它是因为一旦想通某个状态定义，代码往往只有寥寥数行；恨它是因为状态设计依赖对问题结构的深刻洞察，初学时常常「听得懂题解，看见新题还是不会」。

本文尝试把动态规划的思路拆成一个可以重复使用的流程，并用几个经典例题展示它是如何套用的。

## 本质：用空间换时间的递推

DP 的出发点是「最优子结构」——一个大问题可以分解成若干子问题，而原问题的最优解能够由子问题的最优解组合出来。这一点和分治、贪心共享。DP 的独特之处在于它能处理**重叠子问题**：同一个子问题在递归过程中会被反复求解，此时只要把每个子问题的答案记下来，下次直接查表，总时间就能从指数级降到多项式级。

拿斐波那契数列来说，朴素递归 $T(n) = T(n-1) + T(n-2)$ 是 $O(2^n)$：

```cpp
int fib(int n) {
    if (n <= 1) return n;
    return fib(n-1) + fib(n-2);
}
```

同一个 `fib(k)` 会被计算无数次。把结果存起来，就变成 $O(n)$：

```cpp
int fib(int n) {
    vector<int> f(n + 1, 0);
    f[0] = 0; f[1] = 1;
    for (int i = 2; i <= n; ++i) f[i] = f[i-1] + f[i-2];
    return f[n];
}
```

这就是 DP 最朴素的样子。

## 一般流程

1. **定义状态**：明确 `dp[i]`（或 `dp[i][j]`...）的含义。这一步决定了后面所有推导的难度，设计得好，转移方程会自然浮现；设计得不好，就会卡在「怎么写都差一点」的状态里。
2. **写出状态转移方程**：`dp[i]` 如何由若干已知的 `dp[...]` 推出。注意转移要覆盖所有可能的「上一步」。
3. **确定初始化与边界**：最小规模的子问题答案是多少，比如 `dp[0]`、`dp[1]` 等。
4. **确定计算顺序**：一般是小规模到大规模，使得计算 `dp[i]` 时它依赖的那些状态都已经被填好。
5. **回答原问题**：目标往往是某个 `dp[n]` 或者对整张表取最值。

## 经典例题

### 0/1 背包

有 $n$ 件物品，第 $i$ 件重量 $w_i$、价值 $v_i$，背包容量 $W$。每件物品只能选 0 次或 1 次，求最大价值。

**状态**：`dp[i][j]` 表示前 `i` 件物品在容量不超过 `j` 时的最大价值。

**转移**：对第 `i` 件物品，要么不选、要么选：

$$
dp[i][j] = \max(dp[i-1][j],\ dp[i-1][j - w_i] + v_i)
$$

**答案**：`dp[n][W]`。

```cpp
int knapsack01(vector<int>& w, vector<int>& v, int W) {
    int n = w.size();
    vector<vector<int>> dp(n + 1, vector<int>(W + 1, 0));
    for (int i = 1; i <= n; ++i) {
        for (int j = 0; j <= W; ++j) {
            dp[i][j] = dp[i-1][j];
            if (j >= w[i-1])
                dp[i][j] = max(dp[i][j], dp[i-1][j - w[i-1]] + v[i-1]);
        }
    }
    return dp[n][W];
}
```

**空间优化**：`dp[i]` 只依赖 `dp[i-1]`，可以滚成一维数组。关键在于遍历 `j` 时必须**从大到小**，否则 `dp[j - w]` 会被本行覆盖（从而把一件物品用了两次，退化成完全背包）：

```cpp
int knapsack01(vector<int>& w, vector<int>& v, int W) {
    int n = w.size();
    vector<int> dp(W + 1, 0);
    for (int i = 0; i < n; ++i)
        for (int j = W; j >= w[i]; --j)
            dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
    return dp[W];
}
```

### 完全背包

和 0/1 背包几乎一样，区别是每件物品可以选无限次。差别只在一维滚动时 `j` 的遍历方向：**从小到大**，这样 `dp[j - w]` 在本轮已经被更新，就相当于允许重复使用当前物品。

```cpp
for (int i = 0; i < n; ++i)
    for (int j = w[i]; j <= W; ++j)
        dp[j] = max(dp[j], dp[j - w[i]] + v[i]);
```

一个有趣的对比：仅仅是内层循环方向反了一下，就区分开两个问题。

### 最长公共子序列（LCS）

给定两个字符串 $s$ 和 $t$，求它们最长的公共子序列（可以不连续，但顺序不变）。

**状态**：`dp[i][j]` 表示 $s$ 的前 `i` 个字符和 $t$ 的前 `j` 个字符的 LCS 长度。

**转移**：

$$
dp[i][j] = \begin{cases}
dp[i-1][j-1] + 1 & s_i = t_j \\
\max(dp[i-1][j], dp[i][j-1]) & s_i \ne t_j
\end{cases}
$$

```cpp
int lcs(const string& s, const string& t) {
    int n = s.size(), m = t.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    for (int i = 1; i <= n; ++i)
        for (int j = 1; j <= m; ++j)
            dp[i][j] = s[i-1] == t[j-1]
                       ? dp[i-1][j-1] + 1
                       : max(dp[i-1][j], dp[i][j-1]);
    return dp[n][m];
}
```

时间 $O(nm)$，空间可以滚动到 $O(\min(n, m))$。

### 最长上升子序列（LIS）

给定数组 $a$，求最长的严格递增子序列的长度。

**状态**：`dp[i]` 表示以 `a[i]` 结尾的 LIS 长度。

**转移**：`dp[i] = max(dp[j] + 1)`，其中 `j < i` 且 `a[j] < a[i]`。

朴素实现 $O(n^2)$，用二分 + 辅助数组的经典技巧可以优化到 $O(n\log n)$：

```cpp
int lis(vector<int>& a) {
    vector<int> tails;
    for (int x : a) {
        auto it = lower_bound(tails.begin(), tails.end(), x);
        if (it == tails.end()) tails.push_back(x);
        else *it = x;
    }
    return tails.size();
}
```

注意 `tails` 并不是 LIS 本身，而是「所有长度为 $k$ 的 LIS 的最小末尾」——对还原 LIS 需要额外记录前驱。

### 编辑距离

把字符串 $s$ 变成 $t$ 最少需要多少次操作（插入、删除、替换）。

**状态**：`dp[i][j]` 表示把 $s$ 的前 `i` 个字符变成 $t$ 的前 `j` 个字符的最少操作。

**转移**：

$$
dp[i][j] = \begin{cases}
dp[i-1][j-1] & s_i = t_j \\
1 + \min(dp[i-1][j],\ dp[i][j-1],\ dp[i-1][j-1]) & s_i \ne t_j
\end{cases}
$$

三个操作分别对应：删除 $s_i$、插入 $t_j$、替换 $s_i$ 为 $t_j$。

### 区间 DP

区间 DP 的特征是状态定义在一个区间 $[l, r]$ 上，转移时枚举分割点 $k$，把大区间拆成两个子区间。典型例子是「石子合并」：

```cpp
int stones(vector<int>& a) {
    int n = a.size();
    vector<int> pre(n + 1, 0);
    for (int i = 0; i < n; ++i) pre[i+1] = pre[i] + a[i];

    vector<vector<int>> dp(n, vector<int>(n, 0));
    for (int len = 2; len <= n; ++len) {
        for (int l = 0; l + len - 1 < n; ++l) {
            int r = l + len - 1;
            dp[l][r] = INT_MAX;
            for (int k = l; k < r; ++k)
                dp[l][r] = min(dp[l][r],
                               dp[l][k] + dp[k+1][r] + pre[r+1] - pre[l]);
        }
    }
    return dp[0][n-1];
}
```

注意枚举顺序是按区间长度从小到大——小的区间先算，大的区间依赖小的。

## 记忆化搜索 vs 递推

DP 实现上有两种常见形态：

- **自顶向下（memoized recursion）**：按照递归定义写出来，用一张表缓存中间结果。优点是状态转移和递归定义高度对应，容易写、容易调；缺点是递归开销大、栈深度可能爆炸。
- **自底向上（iterative tabulation）**：按计算顺序把 DP 表从最小规模开始逐步填满。优点是常数小、没有栈问题；缺点是要自己想清楚遍历顺序。

两种写法等价，选哪种主要看题目和心情。初学时建议先写记忆化版本，思路通了再翻译成递推。

## 常见的 DP 类型

| 类型 | 状态维度 | 典型题 |
|---|---|---|
| 线性 DP | 一维或二维，按位置推 | 最长递增子序列、打家劫舍 |
| 背包 DP | 物品维 × 容量维 | 0/1、完全、多重、分组背包 |
| 区间 DP | `[l, r]` | 石子合并、回文切割 |
| 树形 DP | 树上每个节点 | 树的直径、树上最大独立集 |
| 状压 DP | 二进制位表示集合 | 旅行商、覆盖问题 |
| 数位 DP | 记忆化 + 进位约束 | 统计一定范围内的符合条件的数 |
| 概率 DP | 浮点状态 | 期望步数、马尔可夫链 |

掌握这些套路之后，大部分 DP 题的难点就只剩下最核心的一步：**恰当地定义状态**。状态一设对，剩下的几乎是机械劳动；状态设错，即便硬套转移方程也无济于事。
