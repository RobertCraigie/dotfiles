/// <reference path="/Users/robert/code/glide/glide/browser/base/content/glide-api.d.ts" />
/// <reference lib="dom" />

// glide.keymaps.set();
// glide.keymaps.set();

glide.g.mapleader = "<Space>";

var toggle = true;

// throw new Error("hmm");

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

glide.keymaps.set("normal", "<leader>g", async () => {
  const tab = (await browser.tabs.query({ active: true }))[0];
  if (!tab) {
    throw new Error("no active tab");
  }

  // const url = new URL(tab.url!);
  // console.log(url);
  // const path_segments = url.pathname.split("/").filter(Boolean);
  // const org = path_segments[0];
  const org = tab
    .url!.split("https://app.stainlessapi.com/")?.[1]
    ?.split("/")[0];
  if (!org) {
    throw new Error("no org path");
  }

  const new_url = `https://stainlessapi.retool.com/app/customers#search=${org}`;
  console.log({ new_url });

  await browser.tabs.create({
    active: true,
    url: new_url,
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
