/// <reference path="./glide.d.ts" />

glide.g.mapleader = "<Space>";

glide.keymaps.set("normal", "<leader>r", "config_reload");

glide.prefs.set("toolkit.legacyUserProfileCustomizations.stylesheets", true);
glide.prefs.set("devtools.debugger.prompt-connection", false);
glide.prefs.set("media.videocontrols.picture-in-picture.audio-toggle.enabled", true);
glide.prefs.set("browser.uidensity", 1); // compact mode
glide.prefs.set("browser.tabs.insertAfterCurrent", true);

glide.keymaps.set("insert", "jj", "mode_change normal");
glide.keymaps.set("normal", ";", "commandline_show");

glide.keymaps.set("normal", "<D-S-c>", "url_yank");

glide.unstable.include("glide.slack.ts");
glide.unstable.include("glide.github.ts");
glide.unstable.include("glide.bearblog.ts");

// useful for sideberry
glide.keymaps.set(["normal", "insert"], "<C-t>", async ({ tab_id }) => {
  await browser.tabs.create({
    active: true,
    index: (await browser.tabs.get(tab_id)).index + 1,
    openerTabId: tab_id,
  });
}, { description: "open a new tab from to the current one" });

// tabs
glide.keymaps.set("normal", "gt", () => go_to_tab("https://tweek.so/"), {
  description: "[g]o to [t]week.so",
});
glide.keymaps.set("normal", "gm", () => go_to_tab("https://messages.google.com/web/*"), {
  description: "[g]o to [m]essages.google.com",
});
glide.keymaps.set("normal", "gw", () => go_to_tab("https://vault.bitwarden.com/*"), {
  description: "[g]o to vault.bit[w]arden.com",
});
glide.keymaps.set("normal", "gl", () => go_to_tab("https://linear.app/*"), {
  description: "[g]o to [l]inear.app",
});
glide.keymaps.set("normal", "gcc", () => go_to_tab("https://calendar.google.com/*"), {
  description: "[g]o to [c]alendar.google.com",
});

async function go_to_tab(url: string) {
  const tab = await glide.tabs.get_first({ url, currentWindow: true });
  if (tab) {
    assert(tab.id);
    await browser.tabs.update(tab.id, { active: true });
  } else {
    const tab_url = url.endsWith("*") ? url.slice(0, -1) : url;
    await browser.tabs.create({ url: tab_url, active: true });
  }
}

// ---------------- styles ----------------
async function register_styles(domain: string) {
  await browser.contentScripts.register({
    matches: [`*://${domain}/*`],
    runAt: "document_start",
    css: [{ code: await glide.fs.read(`styles/${domain}.css`, "utf8") }],
  }).catch((err) => { // TODO: there's a weird return value cloning error
    console.error(err);
  });
}

glide.autocmds.create("ConfigLoaded", async () => {
  await register_styles("tweek.so");
  await register_styles("github.com");
  // await register_styles("news.ycombinator.com");
  await register_styles("marginalia-search.com");
});
// ---------------- /styles ----------------

glide.autocmds.create("UrlEnter", { hostname: "tweek.so" }, async () => {
  glide.buf.keymaps.set("normal", "f", `hint --include="svg"`);
  glide.buf.keymaps.set(
    "normal",
    "<leader>l",
    `hint -s '[d="m14.903 9.482-4.421 4.421c-.346.345-.864.345-1.175 0l-2.21-2.21a.756.756 0 0 1 0-1.14c.31-.346.829-.346 1.174 0l1.624 1.623 3.834-3.834c.31-.345.829-.345 1.174 0 .31.311.31.83 0 1.14Z"]'`,
  );
});

glide.keymaps.set("normal", "<leader>gr", async () => {
  const url = new URL((await glide.tabs.active()).url!);
  const path_segments = url.pathname.split("/").filter(Boolean);
  const org = path_segments[0];
  if (!org) {
    throw new Error("no org path");
  }

  await browser.tabs.create({
    active: true,
    url: `https://stainlessapi.retool.com/app/customers?search=${org}`,
  });
});

// excmds
const surprise = glide.excmds.create({ name: "surprise", description: "" }, () => {
  browser.tabs.create({ active: true, url: "https://wiby.me/surprise/" });
});
/* dprint-ignore */
declare global { interface ExcmdRegistry { surprise: typeof surprise; } }

const shrug = glide.excmds.create({ name: "shrug", description: "" }, async () => {
  const curr_mode = glide.ctx.mode;
  if (curr_mode !== "insert") {
    await glide.excmds.execute(`mode_change insert`);
  }

  await glide.keys.send("¯\\_(ツ)_/¯");

  await glide.excmds.execute(`mode_change ${curr_mode}`);
});
/* dprint-ignore */
declare global { interface ExcmdRegistry { shrug: typeof shrug; } }

glide.keymaps.set("normal", "<leader>ts", "shrug");
glide.keymaps.set("normal", "<leader>\\", "surprise");

// ---------------- stainless ----------------

type StainlessProjects = Array<{ project: string }>;

glide.keymaps.set("normal", "<leader>ss", async () => {
  const data = JSON.parse(
    await glide.fs.read(glide.path.join(glide.path.home_dir, ".dotfiles", "stl-projects.json"), "utf8"),
  ) as StainlessProjects;

  glide.commandline.show({
    title: "stainless projects",
    options: data.map(({ project }) => ({
      label: project,
      async execute() {
        const url = `https://app.stainless.com/${project}/studio`;

        const tab = await glide.tabs.get_first({ url: `${url}*` });
        if (tab) {
          await browser.tabs.update(tab.id, { active: true });
        } else {
          await browser.tabs.create({ active: true, url });
        }
      },
    })),
  });
}, { description: "open a stainless project in the studio" });
// ---------------- /stainless ----------------

