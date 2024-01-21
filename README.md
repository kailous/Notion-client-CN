# Notion-client-CN
Notion 客户端汉化脚本。

---
原来的汉化不能用了,其实官方自己有汉化的，Notion 官方的中文语料正处于 `Development` 阶段，已存在于 Notion 的缓存文件中，这个脚本就是通过修改缓存的配置文件属性让 Notion 客户端加载中文的语言包实现的汉化。

手动汉化的方法如下：
1. 找到 Notion 的缓存文件夹：
    - macOS：`/Users/username/Library/Application Support/Notion/notionAssetCache-v2`
    - Windows：`c:\Users\username\AppData\Roaming\Notion\notionAssetCache-v2`

2. 打开本地缓存文件夹，找到 `latestVersion.json` 文件，并查看最新的版本号，例如 `23.13.0.75`。

3. 打开 `23.12.0.267\assets.json` 文件，查找键值 `localeHtml`，用 `zh-CN` 的键值替换 `en-US` 的键值。

4. 重启 Notion 客户端。

---
## 一键汉化
动手能力强的小伙伴可以自行去修改配置文件实现汉化，但是每次强制刷新后，缓存也会刷新，汉化会失效，脚本其实就是将这个操作自动执行了一遍，使用起来更加方便。

### MacOS
打开 `终端.app` 输入以下命令运行。
```shell
curl -sSL https://raw.githubusercontent.com/kailous/Notion-client-CN/main/run.sh | bash
```
如果不生效，可以尝试下这个
```shell
curl -sSL https://raw.githubusercontent.com/kailous/Notion-client-CN/main/MacOS.sh | bash
```
### Windows
打开 `powershell` 输入以下命令运行。
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kailous/Notion-client-CN/main/Windows.ps1" -UseBasicParsing).Content
```
我手头没有PC，脚本虽然做了PC的适配，但并没有实际测试过，不确定是否会因为某个命令行工具的差异而导致无法运行的情况。如果你遇到了问题欢迎在该项目的[GitHub Issues](https://github.com/kailous/Notion-client-CN/issues)反馈。