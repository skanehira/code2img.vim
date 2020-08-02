" code2img
" Author: skanehira
" License: MIT

let s:open_cmd = get(g:, 'code2img_open_cmd', has('mac') ? 'open' : 'xdg-open')

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echom '[code2img]' a:msg
  echohl None
endfunction

function! s:on_err_vim(ch, msg) abort
  call s:echo_err(a:msg)
endfunction

function! s:on_err_nvim(ch, data, name) abort
  call s:echo_err(a:data)
endfunction

function! s:remove_tmp_on_nvim(tmp, out, id, exit_code, type) abort
  call delete(a:tmp)
  call system(printf('%s %s', s:open_cmd, a:out))
endfunction

function! s:remove_tmp(tmp, out, ch, msg) abort
  call delete(a:tmp)
  call system(printf('%s %s', s:open_cmd, a:out))
endfunction

function! code2img#toimg(first, last, out) abort
  if !executable('code2img')
    call s:echo_err(0, 'not found code2img. please install from https://github.com/skanehira/code2img')
    return
  endif

  let theme = get(g:, 'code2img_theme', 'monokai')
  let ft = &ft

  if ft is# ''
    call s:echo_err(0, 'no extension')
    return
  endif

  let lines = getline(a:first, a:last)

  if len(lines) is# 0
    call s:echo_err(0, 'no source code')
    return
  endif

  let tmp = printf("%s.%s", tempname(), &ft)

  call writefile(lines, tmp)

  if has('nvim')
    let cmd = ['code2img', '-t', theme, tmp, a:out]
    echom cmd
    let id = jobstart(cmd, {
          \ 'on_stderr': function('s:on_err_nvim'),
          \ 'on_exit': function('s:remove_tmp_on_nvim', [tmp, a:out])
          \ })
  else
    call job_start(['code2img', '-ext', &ft, '-t', theme, '-o', a:out], {
          \ 'err_cb': function('s:on_err_vim'),
          \ 'in_io': 'file',
          \ 'in_name': tmp,
          \ 'exit_cb': function('s:remove_tmp', [tmp, a:out])
          \ })
  endif
endfunction
