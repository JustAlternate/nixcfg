{
	programs.nixvim = {
		globals.mapleader = " ";

		keymaps = [
			# Windows
			{
				mode = "n";
				key = "<C-Up>";
				action = "<C-w>k";
				options.desc = "Move To Window Up";
			}

			{
				mode = "n";
				key = "<C-Down>";
				action = "<C-w>j";
				options.desc = "Move To Window Down";
			}

			{
				mode = "n";
				key = "<C-Left>";
				action = "<C-w>h";
				options.desc = "Move To Window Left";
			}

			{
				mode = "n";
				key = "<C-Right>";
				action = "<C-w>l";
				options.desc = "Move To Window Right";
			}

			{
				mode = "n";
				key = "<leader>wd";
				action = "<C-W>c";
				options = {
					silent = true;
					desc = "Delete window";
				};
			}

			{
				mode = "n";
				key = "<leader>-";
				action = "<C-W>s";
				options = {
					silent = true;
					desc = "Split window below";
				};
			}

			{
				mode = "n";
				key = "<leader>|";
				action = "<C-W>v";
				options = {
					silent = true;
					desc = "Split window right";
				};
			}

			# Quit/Session
			{
				mode = "n";
				key = "<leader>qq";
				action = "<cmd>quitall<cr><esc>";
				options = {
					silent = true;
					desc = "Quit all";
				};
			}

			# Better indenting
			{
				mode = "v";
				key = "<";
				action = "<gv";
			}

			{
				mode = "v";
				key = ">";
				action = ">gv";
			}

			# Clear search with ESC
			{
				mode = [
					"n"
					"i"
				];
				key = "<esc>";
				action = "<cmd>noh<cr><esc>";
				options = {
					silent = true;
					desc = "Escape and clear hlsearch";
				};
			}

			# Paste stuff without saving the deleted word into the buffer
			{
				mode = "x";
				key = "p";
				action = "\"_dP";
				options.desc = "Deletes to void register and paste over";
			}

			# Delete to void register
			{
				mode = [
					"n"
					"v"
				];
				key = "<leader>D";
				action = "\"_d";
				options.desc = "Delete to void register";
			}
		];
	};
}
