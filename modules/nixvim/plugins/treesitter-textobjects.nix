{ ... }:
{
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      move = {
        enable = true;
        gotoNextStart = {
          "]f" = {
            query = "@function.outer";
            desc = "Next function start";
          };
          "]c" = {
            query = "@class.outer";
            desc = "Next class start";
          };
        };
        gotoNextEnd = {
          "]F" = {
            query = "@function.outer";
            desc = "Next function end";
          };
          "]C" = {
            query = "@class.outer";
            desc = "Next class end";
          };
        };
        gotoPreviousStart = {
          "[f" = {
            query = "@function.outer";
            desc = "Prev function start";
          };
          "[c" = {
            query = "@class.outer";
            desc = "Prev class start";
          };
        };
        gotoPreviousEnd = {
          "[F" = {
            query = "@function.outer";
            desc = "Prev function end";
          };
          "[C" = {
            query = "@class.outer";
            desc = "Prev class end";
          };
        };
      };
    };
  };
}
