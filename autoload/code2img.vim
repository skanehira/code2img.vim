" code2img
" Author: skanehira
" License: MIT

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echom '[code2img]' a:msg
  echohl None
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

  let theme = get(g:, 'code2img_theme', 'solarized-dark')
  let cmd = ['code2img', '-t', theme, '-ext', &ft]
  if get(g:, 'code2img_line_number', 0)
    let cmd = cmd + ['-l']
  endif
  let cmd += a:0 is# 0 ? ['-c'] : ['-o', a:1]

  let lines += ['']
  if has('nvim')
    echom system(cmd, lines)
  else
    echom system(join(cmd), lines)
  endif
endfunction
