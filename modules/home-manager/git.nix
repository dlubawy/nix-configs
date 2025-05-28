{ vars, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "${vars.email}";
    userName = "${vars.name}";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      key = "${vars.gpgKey}";
      signByDefault = true;
    };
    ignores = [
      # Direnv
      ".direnv"

      # OS
      ".DS_Store"
      "ehthumbs.db"
      "Icon?"
      "Thumbs.db"

      # Editor
      "*~"
      "*.swp"
      "*.swo"
    ];
  };
}
