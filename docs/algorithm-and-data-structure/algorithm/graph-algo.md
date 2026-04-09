# 图算法

图算法是工程实践中最具通用性的一类算法：任务调度、路由规划、编译依赖、社交推荐、网络流量——只要能抽象成「节点 + 边」，就能套用图算法的工具箱。本节以「遍历 → 最短路 → 最小生成树 → 连通分量 → 拓扑排序」为主线，快速过一遍常用的图算法。关于图的基本概念和存储方式，可先阅读 [数据结构篇的图](../data-structure/graph.md)。

## 遍历：DFS 与 BFS

遍历是所有图算法的基础。两者都能在 $O(V + E)$ 时间内访问所有节点和边，区别在于扩展顺序：DFS 一路走到黑，BFS 按层扩展。

```cpp
vector<vector<int>> adj;
vector<bool> vis;

void dfs(int u) {
    vis[u] = true;
    for (int v : adj[u]) if (!vis[v]) dfs(v);
}

void bfs(int s) {
    queue<int> q;
    vis[s] = true;
    q.push(s);
    while (!q.empty()) {
        int u = q.front(); q.pop();
        for (int v : adj[u]) {
            if (!vis[v]) {
                vis[v] = true;
                q.push(v);
            }
        }
    }
}
```

BFS 在**无权图**上天然求单源最短路：因为它逐层推进，第一次访问到某个节点时走的一定是最短路径。

## 单源最短路

给定源点 $s$，求 $s$ 到图中每个其他节点的最短路径长度。按图的特征不同，有不同的最优算法。

### Dijkstra：非负权图

Dijkstra 要求所有边权都是非负的。核心思想是贪心：维护一个已经确定最短路的集合 $S$，每次从 $V \setminus S$ 中挑出当前估计距离最小的节点加入 $S$，然后用这个节点松弛它的邻居。

用二叉堆实现的 Dijkstra 复杂度是 $O((V + E)\log V)$：

```cpp
vector<int> dijkstra(int n, vector<vector<pair<int,int>>>& adj, int s) {
    vector<int> dist(n, INT_MAX);
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;
    dist[s] = 0;
    pq.push({0, s});
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (d > dist[u]) continue;          // 过期条目，跳过
        for (auto [v, w] : adj[u]) {
            if (dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                pq.push({dist[v], v});
            }
        }
    }
    return dist;
}
```

细节：

- 不要写 `if (vis[u]) continue` 然后再 `vis[u] = true`——那样是对的，但代码啰嗦。更简洁的判别是看 `d > dist[u]`，因为同一个节点可能以不同的距离多次入堆，过期条目直接丢弃即可。
- **负权边会让 Dijkstra 静默地给出错答案**。出现负边应该换 Bellman-Ford 或 SPFA。

### Bellman-Ford：允许负权

Bellman-Ford 通过 $V - 1$ 轮对所有边做松弛，每一轮都把「路径最多用 $k$ 条边」的最短路扩展到 $k + 1$ 条边。复杂度 $O(VE)$，速度慢但接受负权。它还可以**检测负环**：如果第 $V$ 轮仍然有松弛发生，说明存在负环。

```cpp
// edges 中每项是 {u, v, w}
bool bellman_ford(int n, vector<tuple<int,int,int>>& edges, int s, vector<long long>& dist) {
    dist.assign(n, LLONG_MAX);
    dist[s] = 0;
    for (int iter = 0; iter < n - 1; ++iter) {
        for (auto [u, v, w] : edges) {
            if (dist[u] != LLONG_MAX && dist[u] + w < dist[v])
                dist[v] = dist[u] + w;
        }
    }
    // 检测负环
    for (auto [u, v, w] : edges) {
        if (dist[u] != LLONG_MAX && dist[u] + w < dist[v]) return false;
    }
    return true;
}
```

### SPFA：队列优化的 Bellman-Ford

SPFA（Shortest Path Faster Algorithm）是用队列跟踪「可能再次松弛邻居」的节点，只有松弛成功的节点才重新入队。最好情况接近 $O(E)$，最坏仍是 $O(VE)$。实践中对稀疏图往往比朴素 Bellman-Ford 快许多，但在一些构造数据上会退化，且工程上不稳定，竞赛里要小心用。

### Floyd-Warshall：全源最短路

Floyd 算法一步到位求出任意两点间最短路，思路极其简洁——三重循环：

```cpp
void floyd(int n, vector<vector<int>>& dist) {
    for (int k = 0; k < n; ++k)
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < n; ++j)
                if (dist[i][k] != INF && dist[k][j] != INF)
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
}
```

复杂度 $O(V^3)$，只适合 $V \le 400$ 左右。`k` 必须在最外层，含义是「允许中间经过的节点集合是 $\{0, 1, \dots, k\}$」。若有负权边，只要没有负环，Floyd 依然正确。

## 最小生成树

给定一张带权无向连通图，求包含所有节点、边权和最小的子树。任何生成树都有恰好 $V - 1$ 条边。

### Kruskal：边为中心

按边权升序考察每条边，如果这条边不会形成环（即两端点不在同一个连通分量），就把它加入生成树。用并查集判断是否成环：

```cpp
struct DSU {
    vector<int> p, r;
    DSU(int n): p(n), r(n, 0) { iota(p.begin(), p.end(), 0); }
    int find(int x) { return p[x] == x ? x : p[x] = find(p[x]); }
    bool unite(int x, int y) {
        x = find(x); y = find(y);
        if (x == y) return false;
        if (r[x] < r[y]) swap(x, y);
        p[y] = x;
        if (r[x] == r[y]) ++r[x];
        return true;
    }
};

int kruskal(int n, vector<tuple<int,int,int>>& edges) {   // {w, u, v}
    sort(edges.begin(), edges.end());
    DSU dsu(n);
    int total = 0, used = 0;
    for (auto [w, u, v] : edges) {
        if (dsu.unite(u, v)) {
            total += w;
            if (++used == n - 1) break;
        }
    }
    return used == n - 1 ? total : -1;    // -1 表示不连通
}
```

复杂度 $O(E\log E)$，瓶颈在排序。

### Prim：点为中心

从任意起点出发，把节点分成「已加入」和「未加入」两半。每次从连接两半的所有边中选最小的，把对应未加入节点纳入。堆优化版和 Dijkstra 结构几乎一样：

```cpp
int prim(int n, vector<vector<pair<int,int>>>& adj) {
    vector<int> dist(n, INT_MAX);
    vector<bool> in(n, false);
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;
    dist[0] = 0;
    pq.push({0, 0});
    int total = 0, cnt = 0;
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (in[u]) continue;
        in[u] = true;
        total += d;
        ++cnt;
        for (auto [v, w] : adj[u])
            if (!in[v] && w < dist[v]) {
                dist[v] = w;
                pq.push({w, v});
            }
    }
    return cnt == n ? total : -1;
}
```

Kruskal 与 Prim 的选择主要看稠密度：稀疏图用 Kruskal，稠密图用 Prim（甚至朴素 $O(V^2)$ 版本都可能更快）。

## 拓扑排序

详见 [数据结构篇的图](../data-structure/graph.md) 中对 Kahn 算法的介绍。拓扑序只对 DAG 存在，工程中任何涉及「先做完 A 才能做 B」的调度问题——编译依赖、CI 流水线、课程编排——都靠它。

## 强连通分量（SCC）

在有向图中，如果一组节点之间两两都能互达，就称这组节点是强连通分量。把每个 SCC 缩成一个点，原图会变成一个 DAG，对后续很多问题都有帮助。

**Tarjan 算法**用一次 DFS 完成 SCC 的求解，核心是维护每个节点的 `dfn`（访问时间戳）和 `low`（能追溯到的最早祖先时间戳）。当 `dfn[u] == low[u]` 时，栈中从 `u` 到栈顶的所有节点构成一个 SCC。

**Kosaraju 算法**更直观但要跑两遍 DFS：第一遍按完成时间逆序记录节点，第二遍在反图上按这个顺序 DFS，每一次 DFS 到的节点集合就是一个 SCC。

两种算法复杂度都是 $O(V + E)$。

## 二分图匹配

二分图判定用 BFS/DFS 染色即可。二分图的最大匹配问题有两种常用解法：

- **匈牙利算法**：通过不断寻找「增广路径」来扩大匹配。实现简单，复杂度 $O(VE)$。
- **Hopcroft-Karp**：在匈牙利的基础上每次找多条增广路，复杂度 $O(E\sqrt V)$。

二分图最大匹配的一个重要对偶：König 定理——二分图的最大匹配数等于最小点覆盖数。

## 网络流

给定一张有向图，每条边带一个容量 $c$，求从源点 $s$ 到汇点 $t$ 的最大流量。经典算法：

- **Ford-Fulkerson**：用任意方式找增广路，容量是整数时复杂度是 $O(E\cdot f)$，其中 $f$ 是最大流。如果用 BFS 找增广路，就是 **Edmonds-Karp**，复杂度 $O(VE^2)$，和最大流大小无关。
- **Dinic 算法**：按距离分层 + 多路增广，复杂度 $O(V^2 E)$，在二分图上可达 $O(E\sqrt V)$，是竞赛和工程中的主力。

除了最大流本身，网络流能被用来建模很多看起来八竿子打不着的问题：二分图最大匹配、最小割（最大流最小割定理）、最小费用最大流、带上下界的可行流等等。这部分是图论里「模型构造」色彩最重的一章。

## 小结

| 问题 | 首选算法 | 复杂度 |
|---|---|---|
| 无权最短路 | BFS | $O(V + E)$ |
| 非负权最短路 | Dijkstra + 堆 | $O((V + E)\log V)$ |
| 允许负权 / 判负环 | Bellman-Ford | $O(VE)$ |
| 全源最短路 | Floyd-Warshall | $O(V^3)$ |
| 最小生成树（稀疏） | Kruskal | $O(E\log E)$ |
| 最小生成树（稠密） | Prim | $O(V^2)$ / $O(E\log V)$ |
| 拓扑排序 | Kahn / DFS | $O(V + E)$ |
| 强连通分量 | Tarjan / Kosaraju | $O(V + E)$ |
| 二分图最大匹配 | 匈牙利 / Hopcroft-Karp | $O(VE)$ / $O(E\sqrt V)$ |
| 最大流 | Dinic | $O(V^2 E)$ |

这张表是速查级别的索引。实际解题时，真正花时间的往往不是套模板，而是「把具体问题抽象成标准图论模型」——这一步才是图算法的艺术所在。
