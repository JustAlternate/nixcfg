_: {
  programs.kitty = {
    enable = true;
    font = {
      name = "Hack";
      size = 15;
    };
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      background_opacity = "0.98";
    };
    extraConfig = ''
      map ctrl+alt+n switch_tab_next
    '';
  };
  programs.tmux = {
    enable = true;
    shell = "\${pkgs.zsh}/bin/zsh";
  };

}
