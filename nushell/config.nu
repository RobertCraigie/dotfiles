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

def --wrapped p [...args: string] {
  ^pnpm ...$args
}

def idea [] {
  let logfile = $"~/.idea-(date now | format date '%Y%m%d-%H%M%S').log"
  job spawn { ^'/Applications/IntelliJ IDEA CE.app/Contents/MacOS/idea' . out+err>| save $logfile }
}

$env.DIRENV_LOG_FORMAT = ""

$env.path ++= [
  "/Users/robert/bin",
  "/Users/robert/.local/bin",
  "/Users/robert/.local/share/bob/nvim-bin",
  "/Users/robert/Library/pnpm",
  "/Users/robert/.cargo/bin",
  "/Users/robert/.dotnet/tools",
  "/Users/robert/go/bin",
  "/nix/var/nix/profiles/default/bin",

  "/opt/homebrew/bin",
  "/opt/homebrew/opt/capstone/lib",
  "/opt/homebrew/opt/libxslt/bin",
  "/opt/homebrew/opt/ruby@3.1/bin",
  "/opt/homebrew/opt/dotnet/bin",
  "/opt/homebrew/opt/libxslt/bin",
]

def tokyo-night-storm-theme [] {
  {
    # --- primitives / table bits ------------------------------------------------
    separator:                "#2ac3de"    # bright cyan
    leading_trailing_space_bg:{ fg: "#24283b" bg: "#414868" }  # subtle highlight
    header:                   { fg: "#7aa2f7" attr: b }        # table headers
    empty:                    "#7dcfff"
    row_index:                { fg: "#bb9af7" attr: b }
    hints:                    "#565f89"     # like tokyonight comments

    bool:                     "#f7768e"     # red/pink
    int:                      "#ff9e64"     # orange numbers
    float:                    "#ff9e64"
    string:                   "#f7768e"     # green strings
    datetime:                 "#7dcfff"     # light cyan
    duration:                 "#73daca"     # teal
    range:                    "#e0af68"     # yellow-ish
    filesize:                 "#73daca"
    binary:                   "#bb9af7"
    nothing:                  "#565f89"
    cell-path:                "#7dcfff"

    # --- syntax shapes (nu "shape_*" tokens) ------------------------------------
    shape_garbage:            { fg: "#c0caf5" bg: "#f7768e" attr: b }

    shape_block:              { fg: "#7aa2f7" attr: b }
    shape_bool:               "#f7768e"
    shape_custom:             { fg: "#c0caf5" attr: b }
    shape_external:           "#7aa2f7"      # command names
    shape_externalarg:        { fg: "#73daca" attr: b }
    shape_filepath:           "#7dcfff"
    shape_flag:               { fg: "#7dcfff" attr: b }
    shape_float:              { fg: "#ff9e64" attr: b }
    shape_globpattern:        { fg: "#7dcfff" attr: b }
    shape_int:                { fg: "#ff9e64" attr: b }
    shape_internalcall:       { fg: "#2ac3de" attr: b }
    shape_list:               { fg: "#7dcfff" attr: b }
    shape_literal:            "#c0caf5"
    shape_nothing:            "#565f89"
    shape_operator:           "#bb9af7"
    shape_pipe:               { fg: "#2ac3de" attr: b }
    shape_range:              { fg: "#e0af68" attr: b }
    shape_record:             { fg: "#7dcfff" attr: b }
    shape_signature:          { fg: "#9ece6a" attr: b }
    shape_string:             "#9ece6a"
    shape_string_interpolation: { fg: "#73daca" attr: b }
    shape_table:              { fg: "#7aa2f7" attr: b }
    shape_variable:           "#c0caf5"
  }
}

$env.config.color_config = (tokyo-night-storm-theme)

$env.config.menus ++= [{
  name: history_menu
  only_buffer_difference: true   # same as default
  marker: "? "                   # same as default
  type: {
    layout: list
    page_size: 10
  }
  style: {
    # normal entries
    text: white_dimmed

    # the currently selected entry
    selected_text: "#73daca"

    # optional “extra” text for some menus; history doesn’t really use it
    description_text: yellow
  }
}]

