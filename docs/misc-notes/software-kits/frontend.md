# 前端网页

考虑到有时会要求快速部署网站，特此整理前端开发学习笔记。主要是用[primevue组件库](https://primevue.org/vite)，配合付费的[primeblocks](https://primeblocks.org/)快捷开发。

## 环境配置

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