" term-runner - wrapper to use Neovim's terminal as a runner
" Maintainer:   David M <david.mejorado@gmail.com>
" Version:      0.5
"
" Inspired from VtrRunner, by Chris Toomey
" https://github.com/christoomey/vim-tmux-runner

if exists('g:term_runner_loaded') || exists(':terminal') == 0
    "finish
endif

" options
let g:term_runner_loaded = 1
let g:term_runner_shell = get(g:, 'term_runner_shell', $SHELL)
let g:term_runner_default_mappings = get(g:, 'term_runner_default_mappings',
    \[{ 'mode': 'n', 'key': '!e', 'fn': 'TermRunner' }
    \,{ 'mode': 'n', 'key': '!t', 'fn': 'TermRunnerTab' }
    \,{ 'mode': 'n', 'key': '!-', 'fn': 'TermRunnerSplit' }
    \,{ 'mode': 'n', 'key': '!\', 'fn': 'TermRunnerVSplit' }
    \,{ 'mode': 'n', 'key': '!f', 'fn': 'TermRunnerFocus' }
    \,{ 'mode': 'n', 'key': '!!', 'fn': 'TermRunnerCmd' }
    \,{ 'mode': 'n', 'key': '!s', 'fn': 'TermRunnerSendLine' }
    \,{ 'mode': 'n', 'key': '!k', 'fn': 'TermRunnerKill' }
    \]
\)

" internal
let s:runner_pid = get(s:, 'runner_pid', 0)

function! s:openrunner(target, ...) abort
    if s:runner_pid != 0
        echom 'You already have an open runner'
    else
        let l:start_writing = (a:0 == 2) ? a:2 : v:false
        let s:term_layout   = printf('TermRunner%s', (a:0 == 1) ? a:1 : '')
        exec 'bot' a:target
        exec printf('terminal//%s', g:term_runner_shell)
        exec printf("file %s", s:term_layout)
        let s:runner_pid = b:terminal_job_id
        if l:start_writing
            startinsert
        else
            exec 'wincmd p'
            stopinsert
        endif
    endif
endfunction

function! s:promtforcommand(prompt) abort
    let l:cmd = input(a:prompt)
    if s:runner_pid == 0
        call <SID>openrunner('wincmd s', 'Split')
    endif
    call s:sendtorunner(l:cmd)
endfunction

function! s:focusrunner() abort
    if s:runner_pid != 0
        let l:winn = bufwinnr(s:term_layout)
        let l:bufn = bufname(s:term_layout)
        if l:winn > -1
            exec l:winn . 'wincmd w'
            startinsert
        elseif l:bufn !=# ''
            exec printf('rightbelow split %s', s:term_layout)
            startinsert
        endif
    else
        call <SID>openrunner('wincmd s', 'Split')
        call <SID>focusrunner()
    end
endfunction

function! s:sendtorunner(cmd) abort
    if s:runner_pid != 0
        call jobsend(s:runner_pid, [a:cmd, ''])
    endif
endfunction

function! s:getvisualrange()
    return getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]
endfunction

function! s:sendrange() range
    if s:runner_pid != 0
        call jobsend(s:runner_pid, add(getline(a:firstline, a:lastline), ''))
    endif
endfunction

function! s:killrunner() abort
    if s:runner_pid != 0
        call jobstop(s:runner_pid)
    endif
endfunction

function! s:clearterm() abort
    let s:runner_pid = 0
    exec printf("bdelete! %s", s:term_layout)
endfunction

augroup TermRunner
    autocmd!
    autocmd TermClose TermRunner* call <SID>clearterm()
augroup END

nnoremap <silent> <Plug>TermRunner          :call <SID>openrunner('', '', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerTab       :call <SID>openrunner('tabedit', 'Tab', v:true)<CR>
nnoremap <silent> <Plug>TermRunnerSplit     :call <SID>openrunner('wincmd s', 'Split')<CR>
nnoremap <silent> <Plug>TermRunnerVSplit    :call <SID>openrunner('wincmd v', 'VSplit')<CR>
nnoremap <silent> <Plug>TermRunnerFocus     :call <SID>focusrunner()<CR>
nnoremap <silent> <Plug>TermRunnerCmd       :call <SID>promtforcommand('runner > ')<CR>
nnoremap <silent> <Plug>TermRunnerSendLine  :call <SID>sendtorunner(getline('.'))<CR>
nnoremap <silent> <Plug>TermRunnerKill      :call <SID>killrunner()<CR>
command! -range TermRunnerSendRange <line1>,<line2>call <SID>sendrange()

for s:mm in g:term_runner_default_mappings
    if empty(maparg('!' . s:mm['key'], s:mm['mode']))
        exec printf('%smap %s <Plug>%s', s:mm['mode'], s:mm['key'], s:mm['fn'])
    endif
endfor
