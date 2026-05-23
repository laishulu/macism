![CI](https://github.com/laishulu/macism/actions/workflows/release.yml/badge.svg)

[[English](https://github.com/laishulu/macism/blob/master/README.md)]
# MacOS 输入源管理器 

这个工具可以从命令行管理 macOS 的输入源，非常适合与 `vim` 和 `emacs` 集成（例如
[sis](https://github.com/laishulu/emacs-smart-input-source)）。 

`macism` 相较于其他类似工具的主要优势在于，它可以可靠地选择 CJKV（中文/日文/韩文
/越南文）输入源。而使用其他工具（例如
[input-source-switcher](https://github.com/vovkasm/input-source-switcher)、
[smartim 的 im-select](https://github.com/ybian/smartim)、
[swim](https://github.com/mitsuse/swim)）切换到 CJKV 输入源时，你会看到菜单栏中
的输入源图标已经改变，但实际上除非你激活其他应用程序然后再切回来，输入源仍然是之
前的。 

## 安装

你可以通过以下任一方式获取可执行文件：

- 通过 brew 安装
    ```
    brew tap laishulu/homebrew
    brew install macism
    ```

- 自行编译
    ```
    git clone https://github.com/laishulu/macism
    cd macism
    make
    ```
- 直接从 [GitHub](https://github.com/laishulu/macism/releases) 下载可执行文件
    
## 使用方法
### 显示版本
```sh
macism --version
```
### 显示前输入源
```sh
macism
```
### 切换输入源
#### 切换，并**规避**该 MacOS bug
若输入源**会触发**该 bug 时，下列命令可以稳定切换：
```
macism SOME_INPUT_SOURCE_ID
```
#### 切换，**不规避**该 MacOS bug
若输入源**不会**触发该 bug 时，下列命令体验更好：
```
macism SOME_INPUT_SOURCE_ID 0
```
#### 自定义 wait 时间（进阶）
第三个参数是 workaround（`TemporaryWindow`）的等待时间（毫秒）。内置默认值是
`150`ms——在 **macOS 26 (Tahoe)** 上实测能完全稳定的最小值。wait 太短时鼠须管
等 CJK 输入法还没完整接管事件流，开始打字时前 1–2 个字符会按上一个输入法漏出。

旧版 macOS 只需要 ~1ms；保守的默认值是为了让老用户在 OS 升级后不会无声 break，
代价是切换延迟略高（通常感知不到）。如果你在旧版 macOS 上想更快，可以传更小的值：
```
macism SOME_INPUT_SOURCE_ID 50
```
在 macOS 26.4.1 实测（连续切换并立即打字）：
- `1`：~30–50% race
- `50`：~5% race
- `100`：几十次测试均稳定
- `150`（默认）：完全稳定

总切换延迟约为 `cold-start + wait`，建议取在你的环境下能稳定工作的最小值。

## 致谢
- [LuSrackhall](https://github.com/LuSrackhall) 在此[讨
  论](https://github.com/rime/squirrel/issues/866#issuecomment-2800561092)中提供
  了关键见解。因此我们有了级别 2 和级别 3 模式。 

