# 前端网页

## 大模型智能体时代下的前端开发

下文可以不看了。有agent直接把前端干碎了。你需要做的只有：

1. 购买claude code（或其他agent）
2. 在[这个网站](https://getdesign.md/)上挑一个你喜欢的样式，保存到本地项目目录的DESIGN.md里
3. 直接对大模型说：`使用vite+react框架，以及ant design UI，设计一个xxx网站，风格按照DESIGN.md规划。阅读 https://ant.design/llms-full.txt 并理解 Ant Design 组件库，在编写 Ant Design 代码时使用这些知识。` 然后模型会自己帮你做好……


## 环境配置

考虑到有时会要求快速部署网站，特此整理前端开发学习笔记。主要是用[primevue组件库](https://primevue.org/vite)，配合付费的[primeblocks](https://primeblocks.org/)快捷开发。

默认nodejs已经安装好了。

首先配置前端库，参考[这里](https://tailwindcss.com/docs/guides/vite#vue)和[这里](https://primeblocks.org/documentation)。

```bash
npm create vite@latest my-project -- --template vue # 新建项目
cd my-project
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
npm install tailwindcss-primeui
npm install primevue @primevue/themes
npm i unplugin-vue-components -D
npm i @primevue/auto-import-resolver -D
npm install primeicons
```

修改配置：

### tailwind.config.js
```js
// tailwind.config.js
module.exports = {
    content: [
        "./index.html",
        "./src/**/*.{vue,js,ts,jsx,tsx}",
    ],
    plugins: [require('tailwindcss-primeui')]
};
```

### src/main.js

```js
// src/main.js
import 'primeicons/primeicons.css'
import { createApp } from 'vue'
import PrimeVue from 'primevue/config';
import Aura from '@primevue/themes/aura';
import './style.css'
import router from './router';
import App from './App.vue'
import Ripple from 'primevue/ripple';
import ToastService from 'primevue/toastservice';
const app = createApp(App);
app.use(PrimeVue, {
    theme: {
        preset: Aura
    }
});
app.use(ToastService);
app.use(router);

app.directive('ripple', Ripple);

app.mount('#app');
```

###  vite.config.js

```js
// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Components from 'unplugin-vue-components/vite';
import {PrimeVueResolver} from '@primevue/auto-import-resolver';
import { fileURLToPath, URL } from 'node:url';
// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [
        PrimeVueResolver()
      ]
    })],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})

```

### src/style.css
```js
// src/style.css 在文件首部添加
@tailwind base;
@tailwind components;
@tailwind utilities;
```

随后，调试时运行`npm run dev`，部署时运行`npm run build`即可


## 快速上线mkdocs静态博客

当前的站点就是使用mkdocs构建的。

### 使用uv run mkdocs serve时热更新失效的解决方案

老老实实`source .venv/bin/activate`然后`mkdocs serve`吧。

!!! danger "AI内容提示"
    以下内容为未经验证的ai生成内容，仅供参考，未必准确。

在使用 `uv run mkdocs serve` 时，MkDocs 的热更新（Live Reload）失效，通常是因为 `uv` 运行时的虚拟环境隔离机制导致依赖缺失，或者路径监听的上下文发生了变化。


**在 uv 环境中补充安装 `watchdog`**

MkDocs 依赖 `watchdog` 库来实现高效的文件系统变动监听。如果你是通过 `uv` 管理依赖的，可能在当前的虚拟环境中没有正确安装或链接 `watchdog`。
请尝试在你的项目中显式添加它：

```bash
uv add watchdog
# 或者如果你使用的是 uv pip：
uv pip install watchdog
```
安装完成后，再次运行 `uv run mkdocs serve`。


**开启脏重载（Dirty Reload）**

如果你的文档项目非常大，或者处于某些特殊的文件系统（如 WSL、Docker 挂载目录）中，文件监听事件可能无法穿透 `uv` 的进程。可以尝试加上 `--dirtyreload` 参数，这不仅能加快重载速度，有时也能绕过监听失效的问题：

```bash
uv run mkdocs serve --dirtyreload
```