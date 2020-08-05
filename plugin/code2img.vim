" code2img
" Author: skanehira
" License: MIT

if has('nvim')
  echohl ErrorMsg
  echo '[code2img.vim] doesn''t support neovim'
  echohl None
  finish
endif

if exists('loaded_code2img')
  finish
endif
let g:loaded_code2img = 1

command! -range Code2img call code2img#toimg(<line1>, <line2>)

nnoremap <silent> <Plug>(Code2img) :<C-u>Code2img<CR>
xnoremap <silent> <Plug>(Code2img) :Code2img<CR>
