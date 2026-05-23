![CI](https://github.com/laishulu/macism/actions/workflows/release.yml/badge.svg)

[[中文](https://github.com/laishulu/macism/blob/master/README.zh-CN.md)]
# MacOS Input Source Manager

This tool manages macOS input sources from the command line, ideal for
integration with `vim` and `emacs`(e.g. 
[sis](https://github.com/laishulu/emacs-smart-input-source)). 

`macism`'s main advantage over other similar tools is that it can reliably 
select CJKV(Chinese/Japanese/Korean/Vietnamese) input source, while with other 
tools (such as
[input-source-switcher](https://github.com/vovkasm/input-source-switcher),
[im-select from smartim](https://github.com/ybian/smartim),
[swim](https://github.com/mitsuse/swim)), when you switch to CJKV input source,
you will see that the input source icon has already changed in the menu bar, but
unless you activate other applications and then switch back, the input source is
actually still the same as before.

## Install

You can get the executable in any of the following ways:

- Install from brew
    ```
    brew tap laishulu/homebrew
    brew install macism
    ```

- compile by yourself
    ```
    git clone https://github.com/laishulu/macism
    cd macism
    make
    ```
- download the executable directly from 
    [github](https://github.com/laishulu/macism/releases)
    
## Usage
### Show version
```sh
macism --version
```
### Show current input source
```sh
macism
```
### Switch input source
#### Switch, with workaround for the MacOS bug
```
macism SOME_INPUT_SOURCE_ID
```
#### Switch, without workaround for the MacOS bug
```
macism SOME_INPUT_SOURCE_ID 0
```
#### Switch with a custom wait time (advanced)
The third argument is the wait time in milliseconds for the workaround
(`TemporaryWindow`). The built-in default is `150`ms — empirically the smallest
fully-stable value for the CJK race on **macOS 26 (Tahoe)**. With a shorter
wait, Squirrel and other CJK IMEs may not fully take over before you start
typing, causing the first 1–2 characters to leak as the previous IME.

Older macOS versions only needed ~1ms; the conservative default means existing
users don't silently break after an OS upgrade, at the cost of a slightly
higher (usually imperceptible) switch latency. If you are on an older macOS and
want it snappier, pass a smaller value:
```
macism SOME_INPUT_SOURCE_ID 50
```
Empirical numbers on macOS 26.4.1 (continuous switching with immediate typing):
- `1`: ~30–50% race rate
- `50`: ~5% race rate
- `100`: stable in dozens of attempts
- `150` (default): fully stable

The total switch latency is roughly `cold-start + wait`, so pick the smallest
value that is reliable for you.

## Thanks
- [LuSrackhall](https://github.com/LuSrackhall) for his key insight in this
  [discussion](
    https://github.com/rime/squirrel/issues/866#issuecomment-2800561092
  ).

