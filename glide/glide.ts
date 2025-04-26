/// <reference path="/Users/robert/code/glide-browser/src/glide/browser/base/content/glide-api.d.ts" />
/// <reference lib="dom" />
/// <reference lib="dom.iterable" />

// glide.keymaps.set();
// glide.keymaps.set();

// TODO
// ln -s userChrome.css "/Users/robert/Library/Application Support/Firefox/Profiles/5agrbjp8.default-default/chrome/userChrome.css"
glide.pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
glide.pref("devtools.debugger.prompt-connection", false);

// TODO: omnibox for stainless studio customers

glide.g.mapleader = "<Space>";

browser.tabs.onUpdated.addListener(async (tab_id, info, tab) => {
  if (info.status !== "complete") {
    return;
  }

  if (!tab.url?.match(/github.com.*\/projects\/.*\/views/)) {
    return;
  }

  // TODO: does this get triggered too much?
  await glide.content.execute(
    () => {
      const boards = document.querySelectorAll('[data-dnd-drop-type="card"]');
      for (const board of boards) {
        for (const node of board.children) {
          const card = node as HTMLElement;
          if (card.dataset["glide"]) {
            // already processed
            continue;
          }

          card.dataset["glide"] = "true";

          const menu =
            card.childNodes[0]!.childNodes[0]!.childNodes[0]!.childNodes[0]!
              .childNodes[0]!;
          const ctx_menu = menu.childNodes[menu.childNodes.length - 1]!
            .childNodes[0] as HTMLElement;

          const button = document.createElement("button");
          button.innerHTML = `done`;
          button.onclick = () => {
            /**
             * Finds a button element with specific text
             * @param parentElement - The parent element to search within
             * @param buttonText - The text to search for
             * @param exact - Whether the match should be exact
             * @returns The first matching button element or null if none found
             */
            function findLiByText(
              parentElement: HTMLElement,
              buttonText: string,
              exact: boolean = false,
            ): HTMLLIElement | null {
              // Get all buttons first
              const buttons = parentElement.querySelectorAll("li");

              // Convert text to lowercase for case-insensitive comparison
              const searchText = buttonText.toLowerCase();

              // Find the first matching button
              for (const button of buttons) {
                const content = (button.textContent || "").toLowerCase();

                if (
                  exact
                    ? content.trim() === searchText.trim()
                    : content.includes(searchText)
                ) {
                  return button;
                }
              }

              return null;
            }

            var observer = new MutationObserver((mutations) => {
              for (const mutation of mutations) {
                // Check if any of the added nodes is your context menu
                for (const node of mutation.addedNodes) {
                  const el = node as HTMLElement;
                  if (!el.classList || !el.classList.contains("sentinel")) {
                    continue;
                  }

                  console.log("found", el);
                  const item = findLiByText(
                    el.parentElement!,
                    "Move to column",
                  );
                  if (!item) {
                    console.log("no item");
                    continue;
                  }

                  console.log("yay");

                  var observer2 = new MutationObserver((mutations) => {
                    for (const mutation of mutations) {
                      // Check if any of the added nodes is your context menu
                      for (const node of mutation.addedNodes) {
                        const el = node as HTMLElement;
                        if (!el.classList.contains("sentinel")) {
                          continue;
                        }

                        console.log("node2", node);
                        const item =
                          el.parentElement!.querySelector('div[name="Done"]');
                        if (!item) {
                          console.log("no item");
                          continue;
                        }
                        item!.click();
                        observer.disconnect();
                      }
                    }
                  });

                  observer2.observe(document.body, {
                    childList: true,
                    subtree: true,
                  });

                  item!.click();
                  observer.disconnect();
                  break;
                }
              }
            });
            observer.observe(document.body, { childList: true, subtree: true });

            ctx_menu.click();
          };

          menu.appendChild(button);
        }
      }
    },
    { tab_id },
  );
});

var toggle = true;

glide.keymaps.set("normal", "<leader>f", "hint");
glide.keymaps.set("normal", "<leader><leader>", "commandline_show tab ");

glide.keymaps.set("normal", "<leader>;", async () => {
  console.log("callback!");
  const tab = (await browser.tabs.query({ active: true }))[0]!;

  function set_body_border_style(css: string) {
    document.body.style.setProperty("border", css);
  }

  await glide.content.execute(set_body_border_style, {
    tab_id: tab.id!,
    args: [toggle ? "20px dotted red" : ""],
  });
  toggle = !toggle;
});

glide.keymaps.set("normal", "<leader>gr", async () => {
  const tab = (await browser.tabs.query({ active: true }))[0];
  if (!tab) {
    throw new Error("no active tab");
  }

  const url = new URL(tab.url!);
  const path_segments = url.pathname.split("/").filter(Boolean);
  const org = path_segments[0];
  if (!org) {
    throw new Error("no org path");
  }

  await browser.tabs.create({
    active: true,
    url: `https://stainlessapi.retool.com/app/customers#search=${org}`,
  });

  //
  //   // Extract path segments and query parameters
  //   const params = new URLSearchParams(url.search);
  //   const language = params.get("language");

  // browser.runtime.onInstalled.addListener(() => {
  //   browser.contextMenus.create({
  //     id: "copyStainlessCommand",
  //     title: "Copy pnpm start command",
  //     contexts: ["page"],
  //     documentUrlPatterns: ["*://app.stainlessapi.com/*"],
  //   });
  // });

  // browser.contextMenus.onClicked.addListener(async (info, tab) => {
  //   if (info.menuItemId !== "copyStainlessCommand") {
  //     return;
  //   }
  //
  //   const url = new URL(tab!.url!);
  //
  //   // Extract path segments and query parameters
  //   const pathSegments = url.pathname.split("/").filter(Boolean);
  //   const params = new URLSearchParams(url.search);
  //   const language = params.get("language");
  //
  //   // Only proceed if we have the expected URL structure
  //   if (pathSegments.length >= 2 && language) {
  //     // Construct the command: "pnpm start org/repo-language"
  //     const org = pathSegments[1];
  //     const repo = pathSegments[2];
  //     const command = `pnpm start ${org}/${repo}-${language}`;
  //
  //     // Copy to clipboard using the background page
  //     const textarea = document.createElement("textarea");
  //     textarea.textContent = command;
  //     document.body.appendChild(textarea);
  //     textarea.select();
  //     document.execCommand("copy");
  //     document.body.removeChild(textarea);
  //
  //     // Optional: Show a notification
  //     await browser.notifications.create({
  //       type: "basic",
  //       iconUrl: "icon48.png",
  //       title: "Command Copied",
  //       message: `Copied: ${command}`,
  //     });
  //   }
  // });
});
