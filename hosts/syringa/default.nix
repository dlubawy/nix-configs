# TODO: need to finish this
{
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../nixos
  ];

  wsl = {
    enable = true;
    defaultUser = "${vars.user}";
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
      enableGUI = false;
    };
  };
}
