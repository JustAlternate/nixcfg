# Custom theme based on edvardm with single spaces and machine name support
# Place this file in ~/.config/zsh/themes/edvardm-custom.zsh-theme

PROMPT='%{$fg_bold[red]%}➜ %{$fg_bold[green]%}%{$fg_bold[white]%}%c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
