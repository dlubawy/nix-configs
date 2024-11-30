{ pkgs, ... }:
let
  dailiesTemplate = ''
    * Daily Intent

    Goal
    ___
    %^{Goal}

    * Log
    ** WIP Daily Tasks [/]

    ** Pings
  '';
  personTemplate = ''
    * %^{Name}
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

    * Birthday   :bday:
      DEADLINE: <yyyy-mm-dd aaa +1y -4w>

    * How We Met
  '';
  resonanaceTemplate = ''
    * %^{Title}
    :PROPERTIES:
    :Type: %^{Type||game|book|movie}
    :Start:
    :Fin:
    :Killed:
    :Rating:
    :Digested:
    :Creator:
    :URL:
    :END:

    ** Actions

    ** Key Ideas

    ** Review

    ** Quotes

    ** Notes
  '';
  weeklyTemplate = ''
    #+TITLE: %<%Yw%V>

    * Intents
      Week Goal:
      |----+--------+-----------+----------+---------+---------+---------------+-----------|
      |    | Mon    | Tue       | Wed      | Thu     | Fri     | Sat           | Sun       |
      |----+--------+-----------+----------+---------+---------+---------------+-----------|
      | 🐧 |        |           |          |         |         |               |           |
      |----+--------+-----------+----------+---------+---------+---------------+-----------|
      | \Delta  |   |           |          |         |         |               |           |
      |----+--------+-----------+----------+---------+---------+---------------+-----------|
    * Commits
      |---------------------------------------+-----------------------------------|
      | *This Week*                           | *Q1 OKRs*                         |
      |---------------------------------------+-----------------------------------|
      | 1. Health:                            | 1.                                |
      | 2. Astro:                             | 2.                                |
      | 3. Coding:                            | 3.                                |
      | 4. PhD:                               | 4.                                |
      | 5. Writing:                           | 5.                                |
      |---------------------------------------+-----------------------------------|
      | *Next 4 Weeks*                        | *Health Metrics*                  |
      |---------------------------------------+-----------------------------------|
      | 1.                                    | 1.                                |
      | 2.                                    | 2.                                |
      | 3.                                    | 3.                                |
      | 4.                                    | 4.                                |
      |---------------------------------------+-----------------------------------|
      Watched:
      Played:
      Read:
    * Buckets
    ** Sharpen
       2 wo/run + movie + game + read
       ⬜ ⬜ ⬜ ⬜
    ** Create
       Blog + Book
       ⬜ ⬜
    ** Invest
       COMA
       ⬜
    ** Learn
       Astro + COMA Airflow + Rust
       ⬜ ⬜ ⬜
    ** Review, Plan, Prune
       Buckets + Weekly Review
       ✅ ⬜
    * Weekly Review
      ⬜✅💪❌🔼🔽¼ ½ ¾ ⅓ ⅔ ⅕ ⅖ ⅗ ⅘
    ** Score: XX/XX ~ XX%
    ** How'd it go?
    ** *🏆 Pluses*
       1.
       2.
       3.
    ** 🔽 Minuses
       1.
       2.
       3.
    ** ▶️ Next
       1.
       2.
       3.
  '';
in
{
  extraConfigLua = ''
    require("orgmode").setup({
      org_agenda_files = {"~/Documents/org/**/*.org"},
      org_default_notes_file = "~/Documents/org/refile.org",
      org_todo_keywords = { 'TODO(t)', 'WIP', 'HOLD', '|', 'DONE', 'CANCELLED' },
    })
    require("org-roam").setup({
      directory = "~/Documents/org",
      templates = {
        d = {
          description = "default",
          template = "* %^{Title}",
          target = "%[slug].org",
        },
        p = {
          description = "person",
          template = [=[${personTemplate}]=],
          target = "%R/refs/prm/%[slug].org",
        },
        r = {
          description = "resonance",
          template = [=[${resonanaceTemplate}]=],
          target = "%R/refs/rez/%[slug].org",
        },
        w = {
          description = "weekly",
          template = [=[${weeklyTemplate}]=],
          target = "%R/logs/%<%Yw%V>.org",
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
      extensions = {
        dailies = {
          directory = "logs",
          templates = {
            d = {
              description = "default",
              template = [=[${dailiesTemplate}]=],
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
        }
      }
    })
    require("telescope").load_extension("orgmode")
    require("org-bullets").setup()
  '';

  extraPackages = with pkgs; [ pandoc ];

  plugins.which-key = {
    # registrations = {
    #   "<leader>" = {
    #     o = {
    #       name = "+orgmode";
    #     };
    #     r = {
    #       name = "+roam";
    #       a = {
    #         name = "+alias";
    #       };
    #       o = {
    #         name = "+origin";
    #       };
    #       d = {
    #         name = "+dailies";
    #       };
    #     };
    #   };
    # };
  };

  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      name = "orgmode";
      src = fetchFromGitHub {
        owner = "nvim-orgmode";
        repo = "orgmode";
        rev = "0.3.5";
        sha256 = "TUw+BSynn5KWGHZ1Qt3pStyLR+cbANTUJLywVrFV5is=";
      };
    })
    (vimUtils.buildVimPlugin {
      name = "org-bullets";
      src = fetchFromGitHub {
        owner = "nvim-orgmode";
        repo = "org-bullets.nvim";
        rev = "ab8e1d860d61239c4fe187ead15f73bb2561acd1";
        sha256 = "HbttsU5uq1RQjI2KBDx/mp+VO94DkJ3N6+1fSHvQNA0=";
      };
    })
    (vimUtils.buildVimPlugin {
      name = "telescope-orgmode";
      src = fetchFromGitHub {
        owner = "nvim-orgmode";
        repo = "telescope-orgmode.nvim";
        rev = "1.3.2";
        sha256 = "N4BH8ysHo5lrQvYtoPCu+TFAmUt8zjzmrEdmr3MBW7A=";
      };
    })
    (vimUtils.buildVimPlugin {
      name = "org-roam";
      src = fetchFromGitHub {
        owner = "chipsenkbeil";
        repo = "org-roam.nvim";
        rev = "0.1.0";
        sha256 = "n7GrZrM5W7QvM7805Li0VEBKc23KKbrxG3voL3otpLw=";
      };
    })
  ];
}
