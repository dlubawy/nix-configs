# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: (import ../pkgs "default" inputs) final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    age-plugin-yubikey = prev.age-plugin-yubikey.overrideAttrs (
      _: (import ./age-plugin-yubikey { inherit prev; })
    );
    fuse-ext2 = prev.fuse-ext2.overrideAttrs (_: (import ./fuse-ext2 { inherit prev final; }));
    ntfs3g = prev.ntfs3g.overrideAttrs (_: (import ./ntfs3g { inherit prev final; }));
    hostapd = prev.hostapd.overrideAttrs (_: (import ./hostapd { inherit prev final; }));
    vimPlugins = prev.vimPlugins // {
      CopilotChat-nvim = prev.vimPlugins.CopilotChat-nvim.overrideAttrs (_: {
        nvimSkipModules = [ "CopilotChat.integrations.fzflua" ];
      });
      render-markdown-nvim = prev.vimPlugins.render-markdown-nvim.overrideAttrs (_: {
        nvimSkipModules = [ "render-markdown.config.patterns" ];
      });
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
