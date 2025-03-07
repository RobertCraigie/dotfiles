# TODO: ad blocker?
# TODO: spellcheck
# TODO: how do you select stuff with keyboard?
# TODO: fix copy to clipboard buttons
# TODO: binding to open kagi with search focused
# TODO: custom bindings for common websites, e.g. claude

# TODO: setup bitwarden integration
# TODO: consider disabling tab view, if possible
# TODO: look into quickmarks / bookmarks
# TODO: look into scrollmarks
# TODO: go through all the settings
# TODO: try and get auto complete / type checking to work for config options
# TODO: is there a userscript for auto rejecting cookies

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
    'open -t https://kagi.com ; jseval -q document.querySelector("input[name=q]").focus()',
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


# TODO
"""
In other browsers I can press `Esc` to close a popover menu, that doesn't appear to work out of the box with qutebrowser in normal or insert mode. I've found thay `Ctrl+Esc` does close the menu visuals but doesn't remove focus which means when I try to scroll, the menu is opened again.

For example, this menu in the github issues page:
<img width="598" alt="Screenshot 2024-10-19 at 22 21 29" src="https://github.com/user-attachments/assets/03f4a4f7-a341-4eea-8247-8d3a411a2a27">

In chromeK
"""
