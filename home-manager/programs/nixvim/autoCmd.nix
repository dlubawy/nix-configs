[
  {
    event = [ "BufWritePre" ];
    pattern = "*";
    callback = {
      __raw = ''
        function(args)
            require("conform").format({ bufnr = args.buf })
        end
      '';
    };
  }

  # gitsigns
  {
    event = [ "ColorScheme" ];
    pattern = "catppuccin-frappe";
    callback = ''
        function()
      		vim.cmd([[
              hi GitSignsChangeInline guifg=#a5adce
              hi GitSignsAddInline guifg=#a5adce
              hi GitSignsDeleteInline guifg=#a5adce
              hi GitSignsCurrentLineBlame guifg=#a5adce
          ]])
      	end
    '';
  }
]
