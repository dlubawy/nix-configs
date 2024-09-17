{ lib, pkgs, ... }:
{
  # Disable Neorg until more mature (using orgmode until then)
  config = lib.mkIf false {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin { inherit (pkgs.luaPackages.lua-utils-nvim) pname version src; })
      (pkgs.vimUtils.buildVimPlugin { inherit (pkgs.luaPackages.pathlib-nvim) pname version src; })
      (pkgs.vimUtils.buildVimPlugin { inherit (pkgs.luaPackages.nvim-nio) pname version src; })
      (pkgs.vimUtils.buildVimPlugin {
        name = "neorg-figlet-module";
        src = pkgs.fetchFromGitHub {
          owner = "madskjeldgaard";
          repo = "neorg-figlet-module";
          rev = "bb3e6283dac7b996cc258a6e0f918155168ae2b6";
          sha256 = "P/sFVO4GPkIhUGgGBfs9CZydqA7Kz7LWQlk8+V6V0Vo=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "neorg-templates";
        src = pkgs.fetchFromGitHub {
          owner = "pysan3";
          repo = "neorg-templates";
          rev = "v2.0.3";
          sha256 = "nZOAxXSHTUDBpUBS/Esq5HHwEaTB01dI7x5CQFB3pcw=";
        };
      })
    ];
    plugins.which-key = {
      registrations = {
        "<leader>" = {
          n = {
            name = "+neorg";
            n = [
              ''<cmd>Neorg<CR>''
              "Neorg"
            ];
            j = [
              ''<cmd>Neorg journal<CR>''
              "Neorg journal "
            ];
            i = [
              ''<cmd>Neorg index<CR>''
              "Neorg index"
            ];
            c = [
              ''<cmd>Neorg capture<CR>''
              "Neorg capture"
            ];
          };
        };
      };
    };
    plugins.neorg = {
      enable = true;
      modules = {
        "core.defaults" = {
          __empty = null;
        };
        "core.concealer" = {
          __empty = null;
        };
        "core.dirman" = {
          config = {
            default_workspace = "desktop";
            workspaces = {
              desktop = "~/Desktop";
              notes = "~/Documents/00-09 System/02 Notes";
            };
          };
        };
        "core.completion" = {
          config = {
            engine = "nvim-cmp";
          };
        };
        "core.export" = {
          config = {
            export_dir = "~/Documents/norg/exports";
          };
        };
        "core.export.markdown" = {
          config = {
            extensions = "all";
          };
        };
        "core.presenter" = {
          config = {
            zen_mode = "zen-mode";
          };
        };
        "core.summary" = {
          __empty = null;
        };
        "external.integrations.figlet" = {
          __empty = null;
        };
        "external.templates" = {
          __empty = null;
        };
      };
    };
    extraFiles = {
      "templates/norg/journal.norg" = ''
        @document.meta
        title: {TODAY_OF_FILETREE}
        description:
        authors: {AUTHOR}
        categories:
        created: {TODAY_OF_FILETREE}
        updated: {TODAY}
        version: 1.0.0
        @end

        * {TODAY_OF_FILETREE}
          #weather {WEATHER}
          {{:{YESTERDAY_OF_FILETREE}:}}[Yesterday] - {{:{TOMORROW_OF_FILETREE}:}}[Tomorrow]

        ** Daily Review
           - {CURSOR}

        ** Today's Checklist
           - ( ) Write my daily review
      '';
      "templates/norg/note.norg" = ''
        @document.meta
        title: {TODAY_OF_FILETREE}
        description:
        authors: {AUTHOR}
        categories:
        created: {TODAY_OF_FILETREE}
        updated: {TODAY}
        version: 1.0.0
        @end

        * {CURSOR}
      '';
      "templates/norg/todo.norg" = ''
        @document.meta
        title: {TODAY_OF_FILETREE}
        description:
        authors: {AUTHOR}
        categories:
        created: {TODAY_OF_FILETREE}
        updated: {TODAY}
        version: 1.0.0
        @end

        * TODO
          - ( ) {CURSOR}
      '';
    };
  };
}
