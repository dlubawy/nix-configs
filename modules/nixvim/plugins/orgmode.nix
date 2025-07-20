{ pkgs, ... }:
{
  extraConfigLua = ''
    require("org-roam").setup({
      directory = "~/Documents/org",
      extensions = {
        dailies = {
          directory = "~/Documents/10-19 Life admin/11 🙋 Me & other living things/11.32 My thoughts, journalling, diaries, & other writing",
        },
      },
      bindings = {
        add_alias = "<leader>raa",
        add_origin = "<leader>roa",
        capture = "<leader>rc",
        complete_at_point = "<leader>r.",
        find_node = "<leader>rf",
        goto_next_node = "<leader>rn",
        goto_prev_node = "<leader>rp",
        insert_node = "<leader>ri",
        insert_node_immediate = "<leader>rm",
        quickfix_backlinks = "<leader>rq",
        remove_alias = "<leader>rar",
        remove_origin = "<leader>ror",
        toggle_roam_buffer = "<leader>rl",
        toggle_roam_buffer_fixed = "<leader>rb"
      },
    })
    require("telescope").load_extension("orgmode")
    require("org-bullets").setup()
  '';

  extraPackages = with pkgs; [ pandoc ];

  plugins = {
    orgmode = {
      enable = true;
      settings = {
        org_agenda_files = [ "~/Documents/org/**/*.org" ];
        org_default_notes_file = "~/Documents/org/01.01 Inbox 📥.org";
        org_todo_keywords = [
          "TODO(t)"
          "NEXT(n)"
          "WAITING(w)"
          "HOLD(h)"
          "|"
          "DONE(d)"
          "CANCELLED(c)"
          "MEETING(m)"
          "PHONE(p)"
        ];
        org_startup_indented = true;
        org_adapt_indentation = false;
        org_capture_templates = {
          t = {
            description = "todo";
            template = "* TODO %?";
          };
          r = {
            description = "respond";
            template = "* NEXT Respond to %^{from} on %^{subject}\nSCHEDULED: %t";
          };
          n = {
            description = "note";
            template = "* %?";
          };
          j = {
            description = "journal";
            template = ''
              *** %<%Y-%m-%d>
              %?
            '';
            target = "~/Documents/org/10-19 Life admin/11 🙋 Me & other living things.org";
            headline = "11.32 My thoughts, journaling, diaries, & other writing";
          };
          h = {
            description = "habit";
            template = ''
              *** NEXT %?
              SCHEDULED: <%<%Y-%m-%d %a> .+1d/3d>
              :PROPERTIES:
              :STYLE: habit
              :REPEAT_TO_STATE: NEXT
              :END:
            '';
            target = "~/Documents/org/10-19 Life admin/11 🙋 Me & other living things.org";
            headline = "11.34 Habits, routines, & planning";
          };
          p = {
            description = "person";
            template = ''
              *** %^{Name}
              :PROPERTIES:
              :Full_Name:
              :Email:
              :Phone:
              :WhatsApp:
              :Telegram:
              :Twitter:
              :Current_Company:
              :Current_Role:
              :Location:
              :END:

              **** %{Name}'s Birthday   :birthday:
              DEADLINE: <yyyy-mm-dd aaa +1y -4w>
            '';
            target = "~/Documents/org/10-19 Life admin/11 🙋 Me & other living things.org";
            headline = "11.01 Inbox 📥";
          };
        };
        org_agenda_custom_commands = {
          p = {
            description = "Personal agenda";
            types = [
              {
                type = "agenda";
                org_agenda_span = "day";
              }
              {
                type = "tags";
                match = ''inbox-ID>"10"'';
                org_agenda_overriding_header = "Tasks to refile";
              }
              {
                type = "tags_todo";
                match = "/NEXT";
                org_agenda_overriding_header = "Next actions";
                org_agenda_todo_ignore_scheduled = "all";
                org_agenda_todo_ignore_deadlines = "all";
              }
              {
                type = "tags_todo";
                match = "/TODO";
                org_agenda_overriding_header = "Tasks";
                org_agenda_todo_ignore_scheduled = "all";
                org_agenda_todo_ignore_deadlines = "all";
              }
            ];
          };
        };
      };
    };
    which-key = {
      settings.spec = [
        {
          __unkeyed = "<leader>o";
          group = "orgmode";
        }
        {
          __unkeyed = "<leader>r";
          group = "roam";
        }
        {
          __unkeyed = "<leader>ra";
          group = "alias";
        }
        {
          __unkeyed = "<leader>ro";
          group = "origin";
        }
        {
          __unkeyed = "<leader>rd";
          group = "dailies";
        }
      ];
    };
  };

  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      name = "org-bullets";
      src = fetchFromGitHub {
        owner = "nvim-orgmode";
        repo = "org-bullets.nvim";
        rev = "21437cfa99c70f2c18977bffd423f912a7b832ea";
        hash = "sha256-/l8IfvVSPK7pt3Or39+uenryTM5aBvyJZX5trKNh0X0=";
      };
      buildInputs = [ vimPlugins.orgmode ];
    })
    (vimUtils.buildVimPlugin {
      name = "telescope-orgmode";
      src = fetchFromGitHub {
        owner = "nvim-orgmode";
        repo = "telescope-orgmode.nvim";
        rev = "1.3.3";
        hash = "sha256-u3ZntL8qcS/SP1ZQqgx5q6zfGb/8L8xiguvsmU1M5XE=";
      };
      buildInputs = [
        vimPlugins.orgmode
        vimPlugins.telescope-nvim
      ];
    })
    (vimUtils.buildVimPlugin {
      name = "org-roam";
      src = fetchFromGitHub {
        owner = "chipsenkbeil";
        repo = "org-roam.nvim";
        rev = "0.1.1";
        hash = "sha256-TrRbZC9PCxtNv4w0rt5WB9sE/iOMY1jCDnP5qwLzRyE=";
      };
      buildInputs = [ vimPlugins.orgmode ];
    })
  ];
}
