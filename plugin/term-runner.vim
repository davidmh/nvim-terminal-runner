" term-runner - wrapper to use Neovim's terminal as a runner
" Maintainer:   David M <david.mejorado@gmail.com>
" Inspired from VtrRunner, by Chris Toomey
" https://github.com/christoomey/vim-tmux-runner

if exists('g:term_runner_loaded') || exists(':terminal') == 0
  finish
endif
let g:term_runner_loaded = 1

let g:term_runner_suggest = get(g:, 'term_runner_suggest', v:false)

let g:term_runner_shell = get(g:, 'term_runner_shell', $SHELL)

let g:term_runner_pid = v:false

function! s:openrunner(target, ...) abort
    let l:start_writing = (a:0 >= 2) ? a:2 : v:false
    " open a new buffer on the specified target
    exec 'bot' a:target
    " start the terminal there
    exec printf('terminal//%s', g:term_runner_shell)
    " grab the job id for the runner
    let g:term_runner_pid = b:terminal_job_id
    " rename the buffer
    file TermRunner
    if l:start_writing
        startinsert
    else
        " return to the previous mark
        exec 'wincmd p'
    endif
endfunction

function! s:sendtorunner(prompt) abort
    let l:cmd = input(a:prompt, '', 'shellcmd')
    if g:term_runner_pid == v:false
        call <SID>openrunner('wincmd s')
    endif
    call jobsend(g:term_runner_pid, [l:cmd, ''])
endfunction

function! s:killrunner() abort
    call jobstop(g:term_runner_pid)
endfunction

augroup TermRunner
    autocmd!
    autocmd TermClose TermRunner let g:term_runner_pid = v:false
augroup END

nnoremap <silent> <Plug>TermRunner       :call <SID>openrunner('', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerTab    :call <SID>openrunner('tabedit', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerSplit  :call <SID>openrunner('wincmd s')<CR>
nnoremap <silent> <Plug>TermRunnerVSplit :call <SID>openrunner('wincmd v')<CR>
nnoremap <silent> <Plug>TermSendCmd      :call <SID>sendtorunner('runner > ')<CR>
nnoremap <silent> <Plug>TermRunnerKill   :call <SID>killrunner()<CR>

let g:term_runner_default_mappings = get(g:, 'term_runner_default_mappings',
    \[
    \{ 'key': 'e', 'fn': 'TermRunner' },
    \{ 'key': 't', 'fn': 'TermRunnerTab' },
    \{ 'key': 's', 'fn': 'TermRunnerSplit' },
    \{ 'key': 'v', 'fn': 'TermRunnerVSplit' },
    \{ 'key': '!', 'fn': 'TermSendCmd' },
    \{ 'key': 'k', 'fn': 'TermRunnerKill' }
    \]
\)

for g:mm in g:term_runner_default_mappings
    if empty(maparg('!' . g:mm['key'], 'n'))
        exec printf('nmap !%s <Plug>%s',  g:mm['key'], g:mm['fn'])
    endif
endfor
