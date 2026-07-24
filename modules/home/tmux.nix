{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 10;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];

    extraConfig = ''
      set -g pane-base-index 1
      set -g renumber-windows on
      set -g focus-events on
      set -g set-clipboard on
      set -sa terminal-features ",xterm-ghostty:RGB:extkeys"
      set -s extended-keys always

      # Windows = workspaces: Ctrl+N (Linux) / Alt+N (macOS via ghostty esc:N)
      bind -n M-1 if-shell 'tmux select-window -t :1' "" 'new-window -t :1'
      bind -n M-2 if-shell 'tmux select-window -t :2' "" 'new-window -t :2'
      bind -n M-3 if-shell 'tmux select-window -t :3' "" 'new-window -t :3'
      bind -n M-4 if-shell 'tmux select-window -t :4' "" 'new-window -t :4'
      bind -n M-5 if-shell 'tmux select-window -t :5' "" 'new-window -t :5'
      bind -n M-6 if-shell 'tmux select-window -t :6' "" 'new-window -t :6'
      bind -n M-7 if-shell 'tmux select-window -t :7' "" 'new-window -t :7'
      bind -n M-8 if-shell 'tmux select-window -t :8' "" 'new-window -t :8'
      bind -n M-9 if-shell 'tmux select-window -t :9' "" 'new-window -t :9'
      bind -n C-1 if-shell 'tmux select-window -t :1' "" 'new-window -t :1'
      bind -n C-2 if-shell 'tmux select-window -t :2' "" 'new-window -t :2'
      bind -n C-3 if-shell 'tmux select-window -t :3' "" 'new-window -t :3'
      bind -n C-4 if-shell 'tmux select-window -t :4' "" 'new-window -t :4'
      bind -n C-5 if-shell 'tmux select-window -t :5' "" 'new-window -t :5'
      bind -n C-6 if-shell 'tmux select-window -t :6' "" 'new-window -t :6'
      bind -n C-7 if-shell 'tmux select-window -t :7' "" 'new-window -t :7'
      bind -n C-8 if-shell 'tmux select-window -t :8' "" 'new-window -t :8'
      bind -n C-9 if-shell 'tmux select-window -t :9' "" 'new-window -t :9'
      bind -n M-t new-window -c "#{pane_current_path}"
      bind -n M-Tab last-window

      # Panes = tiled windows
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
      bind -n M-H resize-pane -L 4
      bind -n M-J resize-pane -D 4
      bind -n M-K resize-pane -U 4
      bind -n M-L resize-pane -R 4
      bind -n M-v split-window -h -c "#{pane_current_path}"
      bind -n M-s split-window -v -c "#{pane_current_path}"
      bind -n M-m resize-pane -Z

      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Status bar: centered, rounded powerline pills (Catppuccin Frappe)
      set -g status-position top
      set -g status-justify centre
      set -g status-interval 3
      set -g status-style "bg=default,fg=#c6d0f5"
      set -g status-left-length 60
      set -g status-right-length 60

      # Session pill (left)
      set -g status-left "#[fg=#ca9ee6,bg=default]#[fg=#232634,bg=#ca9ee6,bold]  #S #[fg=#ca9ee6,bg=default] "

      # Host + clock pills (right)
      set -g status-right "#[fg=#414559,bg=default]#[fg=#a5adce,bg=#414559]  #H #[fg=#414559,bg=default] #[fg=#ca9ee6,bg=default]#[fg=#232634,bg=#ca9ee6,bold]  %H:%M #[fg=#ca9ee6,bg=default]"

      # Each window: index + last-two-path-parts + running command (max 8 chars)
      set -g window-status-separator "  "
      setw -g window-status-format '#[fg=#626880,bg=default]#[fg=#c6d0f5,bg=#626880] #I #[fg=#a5adce,bg=#414559]  #{=/18/…:#{b:pane_current_path}} #[fg=#737994,bg=#414559]→ #[fg=#a5adce,bg=#414559]#{=/8/…:pane_current_command} #[fg=#414559,bg=default]'
      setw -g window-status-current-format '#[fg=#ca9ee6,bg=default]#[fg=#232634,bg=#ca9ee6,bold] #I #[fg=#c6d0f5,bg=#51576d]  #{=/18/…:#{b:pane_current_path}} #[fg=#ef9f76,bg=#51576d]→ #[fg=#a6d189,bg=#51576d,bold]#{=/8/…:pane_current_command} #[fg=#51576d,bg=default]'

      set -g pane-border-style "fg=#51576d"
      set -g pane-active-border-style "fg=#ca9ee6"
      set -g message-style "bg=#ca9ee6,fg=#232634"
    '';
  };
}
