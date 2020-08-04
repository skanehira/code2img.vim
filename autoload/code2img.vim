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

function! s:exit_cb(args, ch, msg) abort
  if a:args.use_clipboard
    if has('mac')
      let cmd = printf('osascript -e "set the clipboard to (read \"%s\" as TIFF picture)"', a:args.out)
      call system(cmd)
    elseif has('linux')
      if executable('xclip')
        let cmd = printf('xclip -i -selection clipboard -t image/png < %s', a:args.out)
        call system(cmd)
      else
        call s:echo_err('not found xclip')
      endif
    else
      call s:echo_err('doesn''t support -clipboard')
    endif

    for f in [a:args.out, a:args.tmp]
      call delete(f)
    endfor
  else
    call delete(a:args.tmp)
    call system(printf('%s %s', s:open_cmd, a:args.out))
  endif
endfunction

function! s:get_arg(args, target) abort
  let i = index(a:args, a:target)

  " if not has only key
  if i isnot# -1 && len(a:args)-1 > i
    let arg = a:args[i+1]
    " if not has only keys likes -o -t
    if arg[0] isnot# '-'
      return arg
    endif
  endif

  return ''
endfunction

function! s:parse_args(args) abort
  if len(a:args) is# 0
    call s:echo_err('invalid args')
    return
  endif

  let use_clipboard = index(a:args, '-clipboard') is# -1 ? 0 : 1
  let theme = s:get_arg(a:args, '-t')
  let out = s:get_arg(a:args, '-o')

  return #{
        \ use_clipboard: use_clipboard,
        \ theme: theme isnot# '' ? theme : get(g:, 'code2img_theme', 'solarized-dark'),
        \ ft: &ft,
        \ out: out isnot# '' ? out : 'out.png'
        \ }
endfunction

function! code2img#toimg(first, last, ...) abort
  if !executable('code2img')
    call s:echo_err(0, 'not found code2img. please install from https://github.com/skanehira/code2img')
    return
  endif

  if &ft is# ''
    call s:echo_err(0, 'no file type')
    return
  endif

  let lines = getline(a:first, a:last)

  if len(lines) is# 0
    call s:echo_err(0, 'no source code')
    return
  endif

  let args = s:parse_args(a:000)
  let args['tmp'] = printf("%s.%s", tempname(), args.ft)

  call writefile(lines, args.tmp)

  call job_start(['code2img', '-ext', args.ft, '-t', args.theme, '-o', args.out], {
        \ 'err_cb': function('s:on_err_vim'),
        \ 'in_io': 'file',
        \ 'in_name': args.tmp,
        \ 'exit_cb': function('s:exit_cb', [args])
        \ })
endfunction

function! code2img#complete(lead, cmdline, curpos) abort
  return ['-o',  '-t', '-clipboard']
endfunction
