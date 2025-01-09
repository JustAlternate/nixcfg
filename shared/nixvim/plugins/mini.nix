_: {
  programs.nixvim.plugins = {
    mini = {
      mockDevIcons = true;
      enable = true;
      modules = {
        icons = {
          style = "glyph";
        };
        # comment = {
        #   options = {
        #     customCommentString = ''
        #       <cmd>lua require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring<cr>
        #     '';
        #   };
        # };
        # Show indent lines
        indentscope = {
          symbol = "│";
          draw.delay = 0;
        };
      };
    };
  };
}
