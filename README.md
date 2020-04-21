## MacOS Input Source Manager

This tool manages MacOS input source from command line, can be integrated with 
`vim` and `emacs` (e.g.
[emacs-smart-input-source](https://github.com/laishulu/emacs-smart-input-source)).
It is based on the codes from [kawa](https://github.com/utatti/kawa).

`macism`'s main advantage over other similar tools is that it can reliably 
select CJKV(Chinese/Japanese/Korean/Vietnamese) input source, while with other 
tools (such as
[input-source-switcher](https://github.com/vovkasm/input-source-switcher),
[im-select from smartim](https://github.com/ybian/smartim),
[swim](https://github.com/mitsuse/swim)), when you switch to CJKV input source,
you will see that the input source icon has already changed in the menu bar, but
unless you activate other applications and then switch back, you input source is
actually still the same as before.

`macism` solve other tools' problem by reading the shortcut key for switching
input sources from the system preference, and then emulate the triggering of the
shortcut key.

### Install

You can get the executable in any of the following ways:

- Install from brew
    ```
    brew tap laishulu/macism
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
    
### Usage

- `macism` will output the current input source
- `macism SOME_INPUT_SOURCE_ID` will select to `SOME_INPUT_SOURCE_ID`.

**Important**:

Your terminal should be granted permission of Accessibility by the following
instructions:

- Apple menu  > System Preferences
- click Privacy, click Accessibility
- then select your terminal app’s tickbox

see also https://support.apple.com/en-gb/guide/mac-help/mh43185/mac
  
### Note

When `macism` simulates the triggering of the shortcut key, it need a tiny 
period time to take effect. The delay is totally acceptable for users, but you 
can't retrive the new input resource immediately in a programmatically way 
without a delay.
