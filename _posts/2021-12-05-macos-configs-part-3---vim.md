---
layout: post
title: "macOS configs part 3 - vim"
description: "Configuring my preferred CLI editor"
date: 2021-12-05
tags: [macOS, configuration, vim, colorscheme, fonts]
---

This post covers how I set up vim to work in my environment. It will also be themed with the Nord colorscheme, and will include some keybinds to navigate my environment quicker.

## Homebrew Installation

Vim can be installed through Homebrew with:

`$ brew install vim`

## Vim Package Manager (vim-plug)

There are a number of package managers explicitly designed for vim. The one I've picked is called [`vim-plug`](https://github.com/junegunn/vim-plug) which the [Nord project links](https://www.nordtheme.com/ports/vim) as a way to install the colorscheme.

Plug first needs to be installed. To do this for a mac, run:

`curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`

Then, the Nord colorscheme is installed by first including the following text at the top of `~/.vimrc`:

```vim
call plug#begin(expand('~/.vim/plugged'))
Plug 'arcticicestudio/nord-vim'
call plug#end()

colorscheme nord
```

save the changes and exit vim (`:wq`), then reopen `~/.vimrc` and type `:PlugInstall` when in NORMAL mode. Close out and reopen the editor again, and you will see the colorscheme applied.

## Custom Statusbar with `vim-airline`

To get the cool lean status bar at the bottom of Vim, I installed a [Vim package called `vim-airline`](https://github.com/vim-airline/vim-airline).

![vim-airline](/assets/images/vim-airline.png){: .center-image}

Simply enter the line `Plug 'vim-airline/vim-airline'` between the `plug#begin(...)` and `plug#end()` sections, and then follow the same method as above to install it with `:PlugInstall`.

If you want to get the neat angular design, add the line `let g:airline_powerline_fonts = 1` underneath the `colorscheme nord` entry:

```vim
...
colorscheme nord

let g:airline_powerline_fonts = 1
```

![vim-airline-powerline](/assets/images/vim-airline-powerline.png){: .center-image}

## Miscellaneous options

Enable the next set of options to show line numbers and syntax:

```vim
syntax enable        " enable syntax highlighting

set autoindent       " autoindent new lines
set number           " Show current line number
set relativenumber   " Show relative line numbers
```

To quickly toggle the line numbers on the left, you can type `:set nu! rnu!`. [This blog post](https://jeffkreeftmeijer.com/vim-number/) goes into great detail about line number options in Vim, complete with gifs.

To show special non-printable characters, add these following 2 lines:

```vim
" Show non-printing characters
set listchars=tab:»\ ,trail:·,nbsp:␣,extends:>,precedes:<
set list
```

The following 3 sets of options are pretty self-explanatory. However, if you want to access the built-in help feature in Vim (as opposed to the far simpler Google search), you can type `:help commandname`, where `commandname` is quite intuitively: the command name.

```vim
" Highlight the current cursor line and column
set cursorline
set cursorcolumn

" Show a visual autocomplete menu
set wildmenu

" search as characters are entered
set incsearch
```

This last option I have in my `vimrc` allows for more powerful backspace behavior. It makes vim backspace over everything in insert mode, which is the intuitive way backspacing works. I include the stackoverflow link so I can quickly reference why I set the option in the first place:

```vim
" source: https://stackoverflow.com/a/11560415
set backspace=indent,eol,start  " more powerful backspacing
```

That wraps it up for my Vim configuration!! Hope it was helpful!

## Resources
- [Nord port for Vim](https://www.nordtheme.com/ports/vim)
- [`vim-plug` Vim package manager](https://github.com/junegunn/vim-plug)
- [`vim-airline` status bar](https://github.com/vim-airline/vim-airline)
- [Vim line numbers disambiguation](https://jeffkreeftmeijer.com/vim-number/)
- [Backspace behavior](https://stackoverflow.com/a/11560415)
