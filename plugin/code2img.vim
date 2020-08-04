" code2img
" Author: skanehira
" License: MIT

if exists('loaded_code2img')
  finish
endif
let g:loaded_code2img = 1

command! -nargs=* -range -complete=customlist,code2img#complete Code2img call code2img#toimg('<line1>', '<line2>', <f-args>)
