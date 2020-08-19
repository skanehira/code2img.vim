# code2img.vim
The Vim plugin that can generate image of source code.

## Usage
```vim
" generate image of file
:Code2img

" generate image of selected range
:'<,'>Code2img
```

## Options
| option               | value                     | descrie           |
|----------------------|---------------------------|-------------------|
| code2img_theme       | solarized-dark            | set color scheme  |
| code2img_line_number | `0` or `1` (default: `0`) | print line number |

## Requirements
- [code2img](https://github.com/skanehira/code2img)
- xclip(linux only)

## Installation
e.g dein.vim

```toml
[[plugins]]
repo = 'skanehira/code2img.vim'
```

## Author
skanehira
