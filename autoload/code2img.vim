" code2img
" Author: skanehira
" License: MIT

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echom '[code2img]' a:msg
  echohl None
endfunction

function! s:on_err_vim(ch, msg) abort
  call s:echo_err(a:msg)
endfunction

function! s:exit_cb(tmp, ch, msg) abort
  call delete(a:tmp)
endfunction

function! code2img#toimg(first, last, ...) abort
  if !executable('code2img')
    call s:echo_err('not found code2img. please install from https://github.com/skanehira/code2img')
    return
  endif

  if &ft is# ''
    call s:echo_err('no file type')
    return
  endif

  let lines = getline(a:first, a:last)

  if len(lines) is# 0
    call s:echo_err('no source code')
    return
  elseif len(lines) is# 1
    let lines = getline(1, '$')
  endif

  let tmp = printf("%s.%s", tempname(), &ft)
  call writefile(lines, tmp)

  let theme = get(g:, 'code2img_theme', 'solarized-dark')

  let cmd = ['code2img', '-t', theme, '-ext', &ft]

  let line = get(g:, 'code2img_line_number', 0)
  if line
    let cmd = cmd + ['-l']
  endif

  let cmd += a:0 is# 0 ? ['-c'] : ['-o', a:1]

  call job_start(cmd, {
        \ 'in_io': 'file',
        \ 'in_name': tmp,
        \ 'err_cb': function('s:on_err_vim'),
        \ 'exit_cb': function('s:exit_cb', [tmp])
        \ })
endfunction
