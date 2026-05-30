{ pkgs, ... }:

{
  # pyright and ruff must be on PATH for helix to spawn them as language servers
  home.packages = with pkgs; [
    pyright  # Python LSP: type checking, completions, hover
    ruff     # Python linter and formatter (also runs as an LSP server)
  ];

  programs.helix = {
    enable = true;

    settings = {
      theme = "tokyonight";

      editor = {
        line-number       = "absolute";
        cursorline        = true;
        color-modes       = true;
        auto-format       = true;
        indent-guides.render = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left  = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-type" ];
        };
      };
    };

    languages = {
      language-server.pyright = {
        command = "pyright-langserver";
        args    = [ "--stdio" ];
      };

      language-server.ruff = {
        command = "ruff";
        args    = [ "server" ];
      };

      language = [
        {
          name             = "python";
          language-servers = [ "pyright" "ruff" ];
          auto-format      = true;
        }
      ];
    };
  };
}
