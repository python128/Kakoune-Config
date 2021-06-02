# from https://git.sr.ht/~ntgg/dotfiles/tree/master/.config/kak/kakrc
#   ___                              _    
#  / __|___ _ __  _ __  __ _ _ _  __| |___
# | (__/ _ \ '  \| '  \/ _` | ' \/ _` (_-<
#  \___\___/_|_|_|_|_|_\__,_|_||_\__,_/__/
#                                         

define-command filetype-hook -params 2 %{
    hook global WinSetOption "filetype=(%arg{1})" "%arg(2)"
}

define-command indent-spaces -params 1 %{
    expandtab
    set-option buffer indentwidth %arg(1)
    set-option buffer softtabstop %arg(1)
    set-option buffer tabstop %arg(1)
}

define-command indent-tabs -params 1 %{
    noexpandtab
    set-option buffer indentwidth %arg(1)
    set-option buffer softtabstop %arg(1)
    set-option buffer tabstop %arg(1)
}

set global tabstop 4
set global indentwidth 0

set global scrolloff 2,5
# set global BOM none
# set global eolformat lf
# set global disabled_hooks .*-trim-indent

# set global autoinfo command|onkey
# set global ui_options terminal_set_title=false ncurses_builtin_key_parser=true
set global ui_options ncurses_assistant=none
# set global scrolloff 2,5
# colorscheme desertex

# from https://github.com/robertmeta/plug.kak
# source plug.kak script
source "%sh{echo $HOME}/.config/kak/plugins/plug.kak/rc/plug.kak"

plug "robertmeta/plug.kak" noload config %{
    set-option global plug_install_dir "%sh{ echo $HOME/.kak-plugins }"
}

# plug "andreyorst/fzf.kak" config %{
#     map global normal <c-p> ': fzf-mode<ret>'
# } defer fzf %{
#     set-option global fzf_file_command 'rg --files --column --no-ignore --hidden --follow -g "!{.git,node_modules,.cache,.cargo,.ccls-cache}/**"'
#     set-option global grepcmd 'rg --files --column --no-ignore --hidden --follow -g "!{.git,node_modules,.cache,.cargo,.ccls-cache}/**"'
# }

# plug "occivink/kakoune-vertical-selection" defer kakoune-vertical-selection %{
# }

# Spell check user mode ──────────────────────────────────────────────────────────────────

declare-user-mode spell
define-command -hidden -params 0 _spell-replace %{
    hook -always -once window ModeChange push:prompt:next-key\[user.spell\] %{
        execute-keys <esc>
    }
    # hook -once -always window ModeChange pop:prompt:normal %{
    #     echo -debug 'DEBUG: user-mode -lock spell hook called.'
    #     enter-user-mode -lock spell
    #     spell
    # }
    hook -once -always window NormalIdle .* %{
        enter-user-mode -lock spell
        spell
    }
    spell-replace
}

map global spell a ': spell-add; spell<ret>' -docstring 'add to dictionary'
map global spell r ': _spell-replace<ret>' -docstring 'suggest replacements'
map global spell n ': spell-next<ret>' -docstring 'next misspelling'
map global spell s ': spell<ret>' -docstring 'show all spelling corrections'

hook global ModeChange push:[^:]*:next-key\[user.spell\] %{
    hook -once -always window NormalIdle .* spell-clear
}

# Status line ──────────────────────────────────────────────────────────────────

# plug "andreyorst/powerline.kak" defer powerline %{
#         #Configure powerline.kak as desired
#         powerline-theme gruvbox
# } config %{
#         powerline-start
# }

#source /home/nexinov/.kak-plugins/powerline.kak/rc/themes/kaleidoscope-dark.kak

colorscheme desertex

plug "jdugan6240/powerline.kak" defer powerline %{
    set-option global powerline_format 'git bufname filetype mode_info line_column position'
    powerline-toggle-module line_column off
    powerline-theme red-phoenix
} config %{
    powerline-start
}

# Status line with git branch info
# from https://github.com/mawww/kakoune/wiki/Status-line#git-branch-integration
# declare-option -docstring "name of the git branch holding the current buffer" \
#     str modeline_git_branch

# hook global WinCreate .* %{
#     hook window NormalIdle .* %{ evaluate-commands %sh{
#     branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
#     if [ -n "${branch}" ]; then
#        printf 'set window modeline_git_branch %%{%s}' "${branch}"
#     fi
#     } }
# }

# hook global WinCreate .* %{ evaluate-commands %sh{
#    is_work_tree=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --is-inside-work-tree 2>/dev/null)
#    if [ "${is_work_tree}" = 'true' ]; then
#        printf 'set-option window modelinefmt %%{%s}' " %opt{modeline_git_branch} | ${kak_opt_modelinefmt}"
#    fi
# }}

# Status line ──────────────────────────────────────────────────────────────────

# Wiki  ──────────────────────────────────────────────────────────────────
# plug "TeddyDD/kakoune-wiki" config %{
#         wiki-setup "~/vimwiki"
# }
# Wiki  ──────────────────────────────────────────────────────────────────

# from https://github.com/alexherbo2/toggle-highlighter.kak
#source "%sh{echo $HOME}/.kak-plugins/prelude.kak/rc/prelude.kak"
#source "%sh{echo $HOME}/.kak-plugins/toggle-highlighter.kak/rc/toggle-highlighter.kak"

#
# LSP  ──────────────────────────────────────────────────────────────────
eval %sh{kak-lsp --kakoune -s $kak_session}
hook global WinSetOption filetype=(rust|python|go|javascript|typescript|c|cpp|java) %{
    lsp-enable-window
}

add-highlighter global/ show-matching
add-highlighter global/ dynregex '%reg{/}' 0:+u
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb
#set-option global ui_options ncurses_status_on_top=true

# From alexherbo2
# Documentation
# – https://github.com/mawww/kakoune/blob/master/doc/pages/highlighters.asciidoc
# – https://github.com/mawww/kakoune/blob/master/doc/pages/faces.asciidoc
#
# Examples
# – https://github.com/mawww/kakoune/blob/master/rc/filetype/crystal.kak

# Highlighter
add-highlighter shared/hawk group -passes colorize|move|wrap
add-highlighter shared/hawk/column column 81 red+r
# add-highlighter shared/hawk/number-lines number-lines -relative -hlcursor 
# add-highlighter shared/hawk/show-whitespaces show-whitespaces

# Command
define-command hawk-toggle -params 1 -docstring 'hawk-toggle <scope>: Toggle Hawk' %{
  toggle-highlighter "%arg{1}/hawk" ref hawk
}

# Mapping
map -docstring 'Hawk mode' global user h ': hawk-toggle window<ret>'

# Keybinds
#
# map global normal <space> , -docstring 'space is my leader'
# map global normal <backspace> <space> -docstring 'remove all sels except main'
# map global normal <a-backspace> <a-space> -docstring 'remove main sel'
map global normal  '#' ': comment-line<ret>' -docstring 'comment line'
map global normal <ret> ':write<ret>' -docstring 'write'
map global normal <c-q> ':quit<ret>' -docstring 'quit'
# map global normal -docstring 'comment block' '<a-#>' ': comment-block<ret>'

# Toggle highlighters
#require-module toggle-highlighter
map global user w ': toggle-highlighter global/wrap wrap -word -width 79<ret>' -docstring 'Toggle wrapping at 79 chars' 
map global user n ': toggle-highlighter global/number-lines number-lines -relative -hlcursor<ret>' -docstring 'Toggle number-lines highlighter'
map global user s ': toggle-highlighter global/show-whitespaces show-whitespaces<ret>' -docstring 'Toggle whitespace highlighter'
# map global user h ': toggle-highlighter global/column_80_red+r column 80 red+r<ret>' -docstring 'Toggle column 80 highlighter'
map global user f '% | fold -w 80 -s' -docstring 'wrap file to 80 char width'
map global user p ': powerline-toggle-module line_column<ret>' -docstring 'toggle line numbers in status line'

# User-modes
map global user g ": enter-user-mode<space>git<ret>" -docstring "Enable Git keymap mode for next key" 
map global user l ': enter-user-mode<space>lsp<ret>' -docstring "Enable lsp keymap mode for next key"
map global user c ': enter-user-mode<space>-lock<space>spell<ret>' -docstring "Enable spell check keymap mode for next key"

declare-user-mode git
map global git -docstring "blame - Show what revision and author last modified each line of the current file" b ': git blame<ret>'
map global git -docstring "blame - hide" B ': git hide-blame<ret>'
map global git -docstring "commit - Record changes to the repository" c ": git commit<ret>"
map global git -docstring "diff - Show changes between HEAD and working tree" d ": git diff<ret>"
map global git -docstring "diff - Hide " D ": git hide-diff<ret>"
map global git -docstring "git - Explore the repository history" g ": repl-new tig<ret>"
# map global git -docstring "github - Copy canonical GitHub URL to system clipboard" h ": github-url<ret>"
map global git -docstring "log - Show commit logs for the current file" l ': repl-new "tig log -- %val{buffile}"<ret>'
map global git -docstring "prompt - Run a free-form Git command prompt" p ": git "
map global git -docstring "status - Show the working tree status" s ': repl-new "tig status"<ret>'
map global git -docstring "staged - Show staged changes" t ": git diff --staged<ret>"
map global git -docstring "write - Write and stage the current file" w ": write<ret>: git add<ret>: git update-diff<ret>"

# Enable <tab>/<s-tab> for insert completion selection
# # ──────────────────────────────────────────────────────
#
hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Helper commands
# # ───────────────
define-command pwd 'echo %sh{pwd}'

# # GTD ──────────────────────────────────────────────────────────────────────────

# declare-option bool gtd

# hook global BufCreate '.*/diary/\d{4}\.md' %{
#   set-option buffer gtd yes
# }

# hook global WinSetOption gtd=true %{

#   require-module gtd
#   evaluate-commands set-option window static_words %opt{gtd_keywords}
#   add-highlighter window/gtd ref gtd

#   alias window gtd gtd-grep-todo
#   alias window g+ gtd-grep-scheduled
#   alias window g! gtd-grep-deadline
#   alias window g+h gtd-grep-hourly
#   alias window g+d gtd-grep-daily
#   alias window g+w gtd-grep-weekly
#   alias window g+m gtd-grep-monthly
#   alias window g+y gtd-grep-yearly

#   map window normal <a-d> ': gtd-jump-to-day<ret>'
#   map window normal <c-d> ': gtd-todo-done<ret>'
#   map window normal <c-u> ': gtd-todo-cancelled<ret>'
#   map window insert <c-y> '<a-;>: gtd-insert-date<ret>'
#   map window insert <c-u> '<a-;>: gtd-insert-time<ret>'

#   hook -always -once window WinSetOption gtd=false %{
#     remove-highlighter window/gtd
#   }
# }

# provide-module gtd %{
#   declare-option -hidden str-list gtd_keywords 'Aborted' 'Buy' 'Call' 'CANCELLED' 'Constat' 'Day' 'Days' 'Deadline' 'DONE' 'Fix' 'Fixed point' 'Fixes' 'Go to' 'Habits' 'Hour' 'Hours' 'How to' 'Month' 'Months' 'Postponed' 'Read' 'Reason' 'Rule' 'Scheduled' 'Status' 'TODO' 'Try' 'Waiting' 'Watch' 'Week' 'Weeks' 'Year' 'Years'

#   add-highlighter shared/gtd regions
#   add-highlighter shared/gtd/code default-region group

#   evaluate-commands %sh{
#     # Keywords
#     eval "set -- $kak_quoted_opt_gtd_keywords"
#     regex="\\b(?:\\Q$1\\E"
#     shift
#     for keyword do
#       regex="$regex|\\Q$keyword\\E"
#     done
#     regex="$regex)\\b"
#     printf "add-highlighter shared/gtd/code/keywords regex '%s' 0:keyword\n" "$regex"
#   }

#   define-command gtd-jump-to-day %{
#     set-register / "^# \K%sh(date '+%F\.%a')$"
#     execute-keys '<space>n'
#     set-register / '^# \K\d{4}-\d{2}-\d{2}\.\w{3}$'
#   }

#   define-command gtd-todo-done %{
#     execute-keys -draft '<a-x>sTODO<ret>cDONE<esc>'
#   }

#   define-command gtd-todo-cancelled %{
#     execute-keys -draft '<a-x>sTODO<ret>cCANCELLED<esc>'
#   }

#   define-command gtd-grep-todo %(grep 'TODO')
#   define-command gtd-grep-scheduled %(grep 'Scheduled')
#   define-command gtd-grep-deadline %(grep 'Deadline')
#   define-command gtd-grep-hourly %(grep '\+\d+Hours?')
#   define-command gtd-grep-daily %(grep '\+\d+Days?')
#   define-command gtd-grep-weekly %(grep '\+\d+Weeks?')
#   define-command gtd-grep-monthly %(grep '\+\d+Months?')
#   define-command gtd-grep-yearly %(grep '\+\d+Years?')

#   define-command gtd-insert-date %(execute-keys -draft '!date ''+%F'' | tr -d ''\n''<ret>')
#   define-command gtd-insert-time %(execute-keys -draft '!date ''+%R'' | tr -d ''\n''<ret>')
# }


# Filetype-specific ────────────────────────────────────────────────────────────

filetype-hook html|markdown|ocaml|gas|nim|latex|yaml %{ indent-spaces 2 }
filetype-hook zig|javascript|haskell|python|rust|kak|c|fish|json|html %{ indent-spaces 4 }

# Grep
hook global WinSetOption filetype=grep %{
  map window normal <ret> ': grep-jump<ret>'
}

# Makefile
hook global WinSetOption filetype=makefile %{
  set-option window indentwidth 0
}

# python
hook global WinSetOption filetype=python %{
  set-option window lsp_server_configuration pyls.configurationSources=["flake8"]
}
