{ ... }:

{
  programs.kitty = {
    enable    = true;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 11.0;
    settings  = {
      background_opacity      = "0.85";
      background_blur         = 1;
      hide_window_decorations = "yes";
    };
    # theme.conf is not tracked in this repo — apply a kitty theme with
    # `kitten themes` after first login, or place your theme file at
    # ~/.config/kitty/theme.conf manually.
    extraConfig = "# include ~/.config/kitty/theme.conf";
  };
}
