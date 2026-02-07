{ ... }:
{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        "*" = [ "trim_whitespace" ];
        docker = [ "trim_newlines" ];
        go = [
          "gofmt"
          "trim_newlines"
        ];
        html = [
          "prettier"
          "trim_newlines"
        ];
        javascript = [
          "prettier"
          "eslint"
          "trim_newlines"
        ];
        just = [
          "just"
          "trim_newlines"
        ];
        lua = [
          "stylua"
          "trim_newlines"
        ];
        make = [ "trim_newlines" ];
        nix = [
          "nixfmt"
          "trim_newlines"
        ];
        python = [
          "ruff_fix"
          "ruff_organize_imports"
          "ruff_format"
          "trim_newlines"
        ];
        rust = [ "rustfmt" ];
        yaml = [
          "prettier"
          "trim_newlines"
        ];
        terraform = [
          "terraform_fmt"
          "trim_newlines"
        ];
        hcl = [
          "terragrunt_hclfmt"
          "trim_newlines"
        ];
      };
      formatters = {
        dbt_sqlfluff = {
          command = "sqlfluff";
          args = [
            "fix"
            "--templater"
            "jinja"
            "--dialect"
            "bigquery"
            "-"
          ];
        };
      };
    };
  };
}
