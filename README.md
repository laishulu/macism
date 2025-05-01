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
    swiftc macism.swift
    ```
- download the executable directly from 
    [github](https://github.com/laishulu/macism/releases)
    
## Usage
1. `macism` will output the current input source
2. `macism SOME_INPUT_SOURCE_ID` will select to `SOME_INPUT_SOURCE_ID`.
3. `macism SOME_INPUT_SOURCE_ID uSECONDS` will select to `SOME_INPUT_SOURCE_ID` 
  with sleep of `uSECONDS` micro seconds. If command pattern #2 does not work in
  your case, try this with `uSECONDS` to be 20000 first, if still does not work,
  increase it. 
4. Add an extra option `--noKeyboardOnly` to command pattern *#2* and *#3* will 
  also enable none-keyboard input sources.

## Thanks
- [LuSrackhall](https://github.com/LuSrackhall) for his key insight in this
  [discussion](
    https://github.com/rime/squirrel/issues/866#issuecomment-2800561092
  ). Based on this insight, macism upgraded from v1 to v2.

