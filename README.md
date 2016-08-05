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
<Plug>TermSendCmd
```

Kill the runner
```
<Plug>TermRunnerKill
```

Default mappings
----------------

|normal mode |maps to                |
|------------|:---------------------:|
|!e          |<Plug>TermRunner       |
|!t          |<Plug>TermRunnerTab    |
|!s          |<Plug>TermRunnerSplit  |
|!v          |<Plug>TermRunnerVSplit |
|!!          |<Plug>TermSendCmd      |
|!k          |<Plug>TermRunnerKill   |

The defaults can be disabled by setting the variable
`g:term_runner_default_mappings`
```
let g:term_runner_default_mappings = []
```

To-do
-----

- gifs
- return to normal mode after opening the runner
- close killed runner
- focus runner
- send current line or visual block to the runner

Inspired from [VtrRunner](https://github.com/christoomey/vim-tmux-runner), by Chris Toomey

