# MacOS Input Source Manager

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

## Install

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
    
## Usage

- `macism` will output the current input source
- `macism SOME_INPUT_SOURCE_ID` will select to `SOME_INPUT_SOURCE_ID`.
- `macism SOME_INPUT_SOURCE_ID uSECONDS` will select to `SOME_INPUT_SOURCE_ID`. 
  If switch from none-CJKV to CJKV, will sleep uSECONDS (default to 20000)
  micro seconds.

## Must Read Note

### About Permission.
The first time when you use `macism SOME_INPUT_SOURCE_ID` in your app (e.g. 
Terminal.app/Emacs.app/iTerm2.app/Alacritty.app), MacOS will popup a window
asking you to grant permission of Accessibility, you can also grant the 
permission manually following the below instructions:

- Apple menu  > System Preferences
- click Privacy, click Accessibility
- select your app's tickbox

see also https://support.apple.com/en-gb/guide/mac-help/mh43185/mac

Be sure to **restart** your app, or the permission will not take effect.
  
### About Keyboard Shortcut

You must enable the MacOS keyboard shortcut for "Select the previous input
source", which can be found in "Preference -> Keyboard -> Shortcuts -> Input
Source".

The shortcut can be anything as your wish, `macism` will read the shortcut from
that entry and trigger it by emulation when needed. Just to make sure you have
already enabled the shortcut.

### About Delay

When `macism` emulates the triggering of the shortcut key, it need a tiny 
period time to take effect. The delay is totally acceptable for users, but you 
can't retrive the new input resource immediately in a programmatical way without
a delay.
