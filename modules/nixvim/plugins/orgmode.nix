{ lib, pkgs, ... }:
let
  orgAgendaFiles = [ "~/Documents/org/**/*.org" ];
  orgDefaultNotesFile = "~/Documents/org/01.01 Inbox 📥.org";
in
{
  extraConfigLua = ''
    require("org-roam").setup({
      directory = "~/Documents/org",
      extensions = {
        dailies = {
          directory = "~/Documents/10-19 Life admin/11 🙋 Me & other living things/11.32 My thoughts, journalling, diaries, & other writing",
          templates = {
            d = {
              description = "diary",
              template = "%?",
              target = "%<%Y-%m-%d>.org",
            },
          },
          bindings = {
            capture_date = "<leader>rdD",
            capture_today = "<leader>rdN",
            capture_tomorrow = "<leader>rdT",
            capture_yesterday = "<leader>rdY",
            find_directory = "<leader>rd.",
            goto_date = "<leader>rdd",
            goto_next_date = "<leader>rdf",
            goto_prev_date = "<leader>rdb",
            goto_today = "<leader>rdn",
            goto_tomorrow = "<leader>rdt",
            goto_yesterday = "<leader>rdy"
          }
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
        org_agenda_files = orgAgendaFiles;
        org_default_notes_file = orgDefaultNotesFile;
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
        org_todo_keyword_faces = {
          TDOD = ":foreground #e78284 :weight bold";
          NEXT = ":foreground #85c1dc :weight bold";
          DONE = ":foreground #a6d189 :weight bold";
          WAITING = ":foreground #ef9f76 :weight bold";
          HOLD = ":foreground #ca9ee6 :weight bold";
          CANCELLED = ":foreground #a6d189 :weight bold";
          MEETING = ":foreground #a6d189 :weight bold";
          PHONE = ":foreground #a6d189 :weight bold";
        };
        org_startup_indented = true;
        org_adapt_indentation = false;
        org_capture_templates = {
          t = {
            description = "todo";
            template = "* TODO %?";
          };
          r = {
            description = "respond";
            template = "* NEXT Respond to %^{From} on %^{Subject}\nSCHEDULED: %t";
          };
          n = {
            description = "note";
            template = "* %?";
          };
          j = {
            description = "journal";
            template = ''
              *** %^{Topic} - %<%Y-%m-%d>
              %U
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
              *** 11.XX+ %^{Name}
              :PROPERTIES:
              :ID: 11.XX+XXX
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

              **** %^{Name}'s Birthday   :birthday:
              DEADLINE: <yyyy-mm-dd aaa +1y -4w>
            '';
            target = "~/Documents/org/10-19 Life admin/11 🙋 Me & other living things.org";
            headline = "11.01 Inbox 📥";
          };
          c = {
            description = "call";
            template = ''
              * PHONE %^{Caller} :phone:
              :LOGBOOK:
              CLOCK: %U
              :END:
              %?
            '';
          };
          m = {
            description = "meeting";
            template = ''
              * MEETING with %^{Who} :meeting:
              :LOGBOOK:
              CLOCK: %U
              :END:
              %?
            '';
          };
        };
        org_agenda_custom_commands = {
          p = {
            description = "Personal agenda";
            types = [
              {
                type = "agenda";
                org_agenda_span = "day";
                org_agenda_tag_filter_preset = "-no_agenda";
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
                match = "-inbox/TODO";
                org_agenda_overriding_header = "Tasks";
                org_agenda_todo_ignore_scheduled = "all";
                org_agenda_todo_ignore_deadlines = "all";
              }
            ];
          };
        };
        mappings = {
          global = {
            org_agenda = "<leader>oA";
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
          __unkeyed = "<leader>oA";
          desc = "org agenda prompt";
        }
        {
          __unkeyed-1 = "<leader>oa";
          __unkeyed-2 = ''<cmd>lua require("orgmode").action("agenda.open_by_key", "p")<CR>'';
          desc = "org agenda";
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
  files = {
    "lua/partials/org_cron.lua" = {
      extraConfigLua = ''
        require('orgmode').cron({
          org_agenda_files = {${lib.strings.concatMapStringsSep "," (x: "'${x}'") orgAgendaFiles}},
          org_default_notes_file = '${orgDefaultNotesFile}',
          notifications = {
            cron_notifier = function(tasks)
              for _, task in ipairs(tasks) do
                local title = string.format('%s (%s)', task.category, task.humanized_duration)
                local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
                local date = string.format('%s: %s', task.type, task.time:to_string())

                -- Linux
                if vim.fn.executable('notify-send') == 1 then
                  vim.system({
                    'notify-send',
                    '--icon=/path/to/orgmode/assets/nvim-orgmode-small.png',
                    '--app-name=orgmode',
                    title,
                    string.format('%s\n%s', subtitle, date),
                  })
                end

                -- MacOS
                if vim.fn.executable('osascript') == 1 then
                  vim.system({'osascript', '-e', string.format('display notification "%s" with title "%s" subtitle "%s"', date, title, subtitle)})
                end
              end
            end
          },
        })
      '';
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
    vimPlugins.org-roam-nvim
  ];
}
