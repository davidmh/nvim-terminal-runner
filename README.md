nvim-term-runner
================

[WIP] wrapper to use Neovim's terminal as a runner

Available functions
-------------------

Open a runner on split | vsplit
```
<Plug>TermRunnerSplit
<Plug>TermRunnerVSplit
```

Open a terminal runner on a tab or on the current window and start typing
```
<Plug>TermRunnerTab
<Plug>TermRunner
```

Send a command to the runner
```
<Plug>TermRunnerCmd
```

Kill the runner
```
<Plug>TermRunnerKill
```

Default mappings
----------------

|normal mode| maps to                     |
|-----------|:----------------------------|
|`!e`       | `<Plug>TermRunner`          |
|`!t`       | `<Plug>TermRunnerTab`       |
|`!-`       | `<Plug>TermRunnerSplit`     |
|`!\`       | `<Plug>TermRunnerVSplit`    |
|`!f`       | `<Plug>TermRunnerFocus`     |
|`!!`       | `<Plug>TermRunnerCmd`       |
|`!s`       | `<Plug>TermRunnerSendLine`  |
|`!k`       | `<Plug>TermRunnerKill`      |

To send a range, you can use `TermRunnerSendRange` in the command line while in visual mode.

The defaults can be disabled by setting the variable
`g:term_runner_default_mappings`
```
let g:term_runner_default_mappings = []
```

To-do
-----

- gifs

Inspired from [VtrRunner](https://github.com/christoomey/vim-tmux-runner), by Chris Toomey
