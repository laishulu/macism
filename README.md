## MacOS Input Source Manager

This tool is used to manage MacOS input source from command line, useful to be 
integrated with `vim` and `emacs`. It is based on the codes from 
[kawa](https://github.com/utatti/kawa).

It's main advantage over other similar tools is that it can reliably select CJKV(
Chinese/Japanese/Korean/Vietnamese) input source, while with other tools (such as
[input-source-switcher](https://github.com/vovkasm/input-source-switcher),
[im-select from smartim](https://github.com/ybian/smartim),
[swim](https://github.com/mitsuse/swim)), when you switch to CJKV input source,
you will see that the input source icon has already changed in the menu bar, but
unless you activate other applications and then switch back, you input source is
actually still the same as before.

This tool overcomes the traditional shortcoming by reading the shortcut key for
switching input sources from the system preference, and then trigger the
shortcut key in a simulated way.

### Install

You can get the executable in any of the following ways:

- compile by yourself
    ```
    git clone https://github.com/laishulu/macism
    cd macism
    swiftc macism.swift
    ```
- download the executable directly from 
    [github](https://github.com/laishulu/emacs-tmux-pane/releases)
    
### Usage

- `macism` will output the current input source
- `macism SOME_INPUT_SOURCE_ID` will select to `SOME_INPUT_SOURCE_ID`.
  
### Note

When `macism` simulates the triggering of the shortcut key, it need a tiny period
time to take effect. The delay is totally acceptable for users, but you can't
retrive the new input resource immediately in a programmatically way without a delay.
