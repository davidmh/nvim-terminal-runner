" term-runner - wrapper to use Neovim's terminal as a runner
" Maintainer:   David M <david.mejorado@gmail.com>
" Version:      0.1
"
" Inspired from VtrRunner, by Chris Toomey
" https://github.com/christoomey/vim-tmux-runner

if exists('g:term_runner_loaded') || exists(':terminal') == 0
    "finish
endif

" options
let g:term_runner_loaded = 1
let g:term_runner_suggest = get(g:, 'term_runner_suggest', v:false)
let g:term_runner_shell = get(g:, 'term_runner_shell', $SHELL)
let g:term_runner_default_mappings = get(g:, 'term_runner_default_mappings',
    \[{ 'key': 'e', 'fn': 'TermRunner' }
    \,{ 'key': 't', 'fn': 'TermRunnerTab' }
    \,{ 'key': 's', 'fn': 'TermRunnerSplit' }
    \,{ 'key': 'v', 'fn': 'TermRunnerVSplit' }
    \,{ 'key': 'f', 'fn': 'TermRunnerFocus' }
    \,{ 'key': '!', 'fn': 'TermRunnerCmd' }
    \,{ 'key': 'k', 'fn': 'TermRunnerKill' }
    \]
\)

" internal
let s:runner_pid = v:false

function! s:openrunner(target, ...) abort
    if s:runner_pid != v:false
        return 'You already have an open runner'
    else
        let l:start_writing = (a:0 >= 1) ? a:1 : v:false
        exec 'bot' a:target
        exec printf('terminal//%s', g:term_runner_shell)
        file TermRunner
        let s:runner_pid = b:terminal_job_id
        if l:start_writing
            startinsert
        else
            exec 'wincmd p'
            stopinsert
        endif
    endif
endfunction

function! s:sendtorunner(prompt) abort
    let l:cmd = input(a:prompt, '', 'shellcmd')
    if s:runner_pid == v:false
        call <SID>openrunner('wincmd s')
    endif
    call jobsend(s:runner_pid, [l:cmd, ''])
endfunction

function! s:killrunner() abort
    call jobstop(s:runner_pid)
endfunction

function! s:clearterm() abort
    let s:runner_pid = v:false
    bdelete! TermRunner
endfunction

function! s:focusrunner() abort
    if s:runner_pid == v:false
        echom 'No runner to zoom into'
    else
        tabnew TermRunner
        startinsert
    end
endfunction

augroup TermRunner
    autocmd!
    autocmd TermClose TermRunner call <SID>clearterm()
augroup END

nnoremap <silent> <Plug>TermRunner       :call <SID>openrunner('', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerTab    :call <SID>openrunner('tabedit', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerSplit  :call <SID>openrunner('wincmd s')<CR>
nnoremap <silent> <Plug>TermRunnerVSplit :call <SID>openrunner('wincmd v')<CR>
nnoremap <silent> <Plug>TermRunnerFocus  :call <SID>focusrunner()<CR>
nnoremap <silent> <Plug>TermRunnerCmd    :call <SID>sendtorunner('runner > ')<CR>
nnoremap <silent> <Plug>TermRunnerKill   :call <SID>killrunner()<CR>

for s:mm in g:term_runner_default_mappings
    if empty(maparg('!' . s:mm['key'], 'n'))
        exec printf('nmap !%s <Plug>%s',  s:mm['key'], s:mm['fn'])
    endif
endfor
