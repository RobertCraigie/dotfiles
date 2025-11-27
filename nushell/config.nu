# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.config.show_banner = false

$env.config.buffer_editor = "nvim"
$env.config.edit_mode = 'vi'

$env.config.cursor_shape = {
  emacs:      line          # used only when edit_mode = emacs
  vi_insert:  line          # thin beam while typing
  vi_normal:  block         # <── solid block when you hit <Esc>
}

$env.config = {
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
      }
    }]
  }
}

def fcp [] {
  fzf | tr -d '\n' | xclip -selection clipboard
}

alias p = pnpm

$env.path ++= [
  "/Users/robert/bin",
  "/Users/robert/.local/bin",
  "/Users/robert/.local/share/bob/nvim-bin",

  "/opt/homebrew/opt/capstone/lib",
  "/opt/homebrew/opt/libxslt/bin",
  "/opt/homebrew/opt/ruby@3.1/bin",
  "/opt/homebrew/opt/dotnet/bin",
  "/opt/homebrew/opt/libxslt/bin",
]
