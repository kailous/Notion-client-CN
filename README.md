# Notion-client-CN
Notion 客户端汉化脚本。

---

~~原来的汉化不能用了,其实官方自己有汉化的，Notion 官方的中文语料正处于 `Development` 阶段，已存在于 Notion 的缓存文件中，这个脚本就是通过修改缓存的配置文件属性让 Notion 客户端加载中文的语言包实现的汉化。~~

没想到Notion的缓存机制太不稳定了，经常会出现即便修改了配置了，也不会生效的情况，所以这次修改了脚本的逻辑，还是得用[Reamd7/notion-zh_CN](https://github.com/Reamd7/notion-zh_CN)的方法，直接修改 Notion 客户端的原始文件，这样就不会出现缓存不生效的情况了。里面修改了 Notion 中 renderer 中 localStorage 的 locale 缓存值，和配置文件`/resources/app.asar/app/.webpack/main/index.js`.以此来应用官方的中文语料。

手动汉化的方法如下：
1. 找到 Notion 的安装目录下的 `/resources/app.asar` 文件，先将其复制并备份到其他地方比如，创建一个 `backup` 文件夹，然后将 `app.asar` 文件复制到 `backup` 文件夹中。

2. 使用 `asar` 工具解压 `app.asar` 文件，得到一个 `app` 文件夹。

3. 打开 `app` 文件夹，显示隐藏文件，找到 `.webpack` 文件夹，打开 `main` 文件夹，找到 `index.js` 文件，用文本编辑器打开。

4. 搜索 `localeHtml` 
    找到如下代码：
    ```js
    localeHtml[r]
    ```
    将其修改为（简体中文）：
    ```js
    localeHtml["zh-CN"]
    ```
    或者 （繁体中文）：
    ```js
    localeHtml["zh-TW"]
    ```
    保存文件。

5. 搜索 `requestReturnedAsIndexV2` 
    找到如下代码：
    ```js
    const e = l.default.join(i, u.path);
    ```
    这是文件的绝对路径 在下方直接注入以下代码, 目的是修改 renderer 中 localStorage 的 locale 缓存值
    ```js
    if (u.path.endsWith('.html')) {
        const fs = require('fs');
        const htmlContent = fs.readFileSync(e, 'utf-8')
        if (!htmlContent.includes(`{"id":"KeyValueStore2:preferredLocale","value":"zh-CN","timestamp":Date.now(),"important":true}`)) {
            (() => {
                fs.writeFileSync(e, htmlContent.replace("</html>", `<script>
                // ==UserScript==
                try {
                    const preferredLocaleStr = window.localStorage.getItem(
                    "LRU:KeyValueStore2:preferredLocale"
                    );
                    const preferredLocale = JSON.parse(preferredLocaleStr) || {"id":"KeyValueStore2:preferredLocale","value":"zh-CN","timestamp":Date.now(),"important":true};
                    if (preferredLocale.value) {
                        preferredLocale.value = "zh-CN";
                    }
                    window.localStorage.setItem(
                        "LRU:KeyValueStore2:preferredLocale",
                        JSON.stringify(preferredLocale)
                    );
                } catch (e) {}
                </script>
                </html>`))
            })();
        }
    }
    ```
    保存文件。

---
## 自动化脚本
动手能力强的小伙伴,或者不想使用脚本的小伙伴可以按照上面的步骤手动汉化。如果你不想动手，下面是写好的自动化脚本。脚本直接下载 [Reamd7/notion-zh_CN](https://github.com/Reamd7/notion-zh_CN) 制作好的`app`文件包到 Notion 应用根目录并解压出来，然后将原始文件和自动更新的脚本移动到`backup`文件夹中完成备份，完成后自动重启或者打开 Notion 客户端。

并没有使用脚本解包修改后再打包的方式，而是直接下载修改好的文件包是考虑可能不是每个人都有 `asar` 解包工具，同时也避免脚本过于复杂，需要第三方库的依赖。

点击可以查看脚本的源码。[MacOS](https://raw.githubusercontent.com/kailous/Notion-client-CN/main/MacOS.sh) & [Windows](https://raw.githubusercontent.com/kailous/Notion-client-CN/main/Windows.ps1),执行脚本前请先阅读脚本的源码，是一个好的习惯，可以避免脚本中的恶意代码对你的电脑造成损害。

不过本人可以保证，此脚本不含任何恶意代码，内部写了详细的注释，另外还写了一些错误处理的代码，会提供详细的错误信息，如果你遇到了问题，欢迎在该项目的[GitHub Issues](https://github.com/kailous/Notion-client-CN/issues)贴出错误信息，方便我收集问题，修复脚本。


### MacOS
打开 `终端.app` 输入以下命令运行。
```shell
curl -sSL https://raw.githubusercontent.com/kailous/Notion-client-CN/main/MacOS.sh | bash
```
### Windows
打开 `powershell` 输入以下命令运行。
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kailous/Notion-client-CN/main/Windows.ps1" -UseBasicParsing).Content
```
我手头没有PC，虽然做了powershell的脚本，但并没有实际测试过，不确定是否会因为环境差异而导致无法运行的情况。如果你遇到了问题欢迎在该项目的[GitHub Issues](https://github.com/kailous/Notion-client-CN/issues)反馈，如果你成功了，也欢迎在该项目的[GitHub Issues](https://github.com/kailous/Notion-client-CN/issues)反馈，让我知道脚本是可以正常运行的。