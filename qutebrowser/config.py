# TODO: ad blocker?
# TODO: spellcheck
# TODO: how do you select stuff with keyboard?
# TODO: fix copy to clipboard buttons
# TODO: binding to open kagi with search focused
# TODO: custom bindings for common websites, e.g. claude

# TODO: how to go back to last tab? builtin binding?
# TODO: custom command for close-preview-prs???
# TODO: https://github.com/qutebrowser/qutebrowser/issues/4397
# TODO: fix theme in https://tomeraberba.ch/the-making-of-keyalesce

# TODO: quicklink for google calendar, claude, github
# TODO: is there a way to change how select works when there's one entry? idk
# TODO: map jj to escape in insert mode
# TODO: setup bitwarden integration
# TODO: consider disabling tab view, if possible
# TODO: look into quickmarks / bookmarks
# TODO: look into scrollmarks
# TODO: go through all the settings
# TODO: try and get auto complete / type checking to work for config options
# TODO: is there a userscript for auto rejecting cookies
# TODO: support cmd+} for tab navigation in insert mode

# TODO: fix insert-mode detection for
# - [ ] github review assigner
# - [ ] claude.ai homepage
# - [ ] kagi homepage, or the `gs` binding
# - [ ] read issue about blinking cursor in normal mode
# - [ ] notion search button
# - [ ] replying to github review comments, also doesn't work for ;t
# - [ ] linear inputs

# passthroughs:
# - [ ] bkspce on linear.app

# sites with bad dark mode handling
# - edinburgh city council
# - zoom join meeting

# exit insert mode when
#  - [ ] github PR comment left

from typing import TYPE_CHECKING, Any, cast

if TYPE_CHECKING:
    # from qutebrowser.config.config import ConfigContainer
    from qutebrowser.config.configfiles import ConfigAPI
    from .config_types import ConfigContainer

    c: ConfigContainer = cast(Any, ...)
    config: ConfigAPI = cast(Any, ...)

config.load_autoconfig()

# ------ config ------

# auto restore tabs, window size
c.auto_save.session = True
c.auto_save.interval = 15000  # Save every 15 seconds
c.session.lazy_restore = True
c.session.default_name = "default"

# tabs
c.tabs.select_on_remove = "last-used"
c.tabs.show_switching_delay = 0

c.content.pdfjs = True
c.content.javascript.clipboard = "access"

# search engines
c.url.searchengines = {
    "DEFAULT": "https://www.kagi.com/search?q={}",
    "qw": "https://www.qwant.com/?q={}",
    "ddg": "https://duckduckgo.com/?q={}",
    "g": "https://www.google.com/search?q={}",
}

# ------ bindings ------
config.bind("<Cmd-Shift-[>", "tab-prev")
config.bind("<Cmd-Shift-]>", "tab-next")

# make esc in insert mode remove focus, so that scrolling works
config.bind(
    "<Escape>", "mode-leave ;; jseval -q document.activeElement.blur()", mode="insert"
)

# TODO: unbind "g-s" "g s"
config.bind(
    "gs",
    "open -t https://kagi.com ;; mode-enter insert",
)

# reverse default tab navigation ordering
config.unbind("J", mode="normal")
config.unbind("K", mode="normal")
config.bind("J", "tab-prev", mode="normal")
config.bind("K", "tab-next", mode="normal")

# ------ theme ------

theme_path = config.configdir / "theme.py"


def setup_theme() -> None:
    from urllib.request import urlopen

    if not theme_path.exists():
        theme = "https://raw.githubusercontent.com/catppuccin/qutebrowser/main/setup.py"
        with urlopen(theme) as themehtml:
            with open(config.configdir / "theme.py", "a") as file:
                file.writelines(themehtml.read().decode("utf-8"))

    if theme_path.exists():
        import theme  # type: ignore

        theme.setup(c, "macchiato", True)


setup_theme()
