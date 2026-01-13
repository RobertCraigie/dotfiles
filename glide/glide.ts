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
glide.keymaps.set("normal", "gz", () => go_to_tab("https://glide.zulipchat.com/*"), {
  description: "[g]o to glide.[z]ulipchat.com",
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

type GitHubRepoIndex = Record<string, number>;

glide.autocmds.create("ConfigLoaded", async () => {
  const index_path = glide.path.join(glide.path.home_dir, ".cache", "glide-github-repos.json");
  if (!(await glide.fs.exists(index_path))) {
    await glide.fs.write(index_path, "{}");
  }

  const index = await glide.fs.read(index_path, "utf8").then((contents) => JSON.parse(contents) as GitHubRepoIndex);
  let write_id: number | null = null;

  function add_to_index(item: Browser.History.HistoryItem) {
    if (!item.url) return;

    const url = new URL(item.url);
    if (url.hostname !== "github.com") return;

    const parts = url.pathname.split("/").slice(1);
    if (parts.length < 2) return;

    const [owner, repo] = parts as [string, string];
    const key = `${owner}/${repo}`;

    index[key] ??= 0;
    index[key] += 1;

    if (write_id) {
      clearTimeout(write_id);
    }

    write_id = setTimeout(() => {
      glide.fs.write(
        index_path,
        JSON.stringify(Object.fromEntries(Object.entries(index).sort(([_, a], [__, b]) => b - a)), null, 2),
      );
    }, 5000);
  }

  browser.history.onVisited.addListener(add_to_index);

  glide.excmds.create({ name: "start_github_repo_index" }, () => {
    (async () => {
      const items = await browser.history.search({
        text: "",
        startTime: 0,
        maxResults: 100000,
      });
      for (const item of items) {
        add_to_index(item);
      }
    })();
  });

  glide.keymaps.set("normal", "<leader>sg", () =>
    glide.commandline.show({
      title: "github repos",
      options: Object.entries(index).sort(([_, a], [__, b]) => b - a).map(([repo]): glide.CommandLineCustomOption => ({
        label: repo,
        async execute() {
          const url = `https://github.com/${repo}`;
          const tab = await glide.tabs.get_first({ url: `${url}*`, currentWindow: true });
          if (tab) {
            await browser.tabs.update(tab.id, { active: true });
          } else {
            await browser.tabs.create({ active: true, url });
          }
        },
      })),
    }), { description: "Search GitHub repos" });
});

// ---------------- stainless ----------------

glide.unstable.include("~/.config/glide/plugins/stainless.glide/stainless.glide.ts");
glide.keymaps.set("normal", "<leader>ss", "stl_pick_studio");
glide.keymaps.set("normal", "<leader>gs", "stl_go_to_studio");

// ---------------- /stainless ----------------

glide.keymaps.set("normal", "p", "keys <D-v>");

glide.keymaps.set("normal", "<leader>tt", () => {
  const id = "hide-toolbox";
  if (!glide.styles.has(id)) {
    glide.styles.add(
      css`
        #navigator-toolbox {
          display: none !important;
        }
      `,
      { id: "hide-toolbox" },
    );
  } else {
    glide.styles.remove("hide-toolbox");
  }
});

const UI_SCALE_STEP = 10;
const UI_SCALE_MIN = 50;
const UI_SCALE_MAX = 250;

function get_ui_scale(): number {
  const current = glide.prefs.get("ui.textScaleFactor");
  return typeof current === "number" ? current : 100;
}

function set_ui_scale(next: number) {
  const clamped = Math.max(UI_SCALE_MIN, Math.min(UI_SCALE_MAX, next));
  glide.prefs.set("ui.textScaleFactor", clamped);
  console.log(`ui.textScaleFactor set to ${clamped}`);
}

glide.keymaps.set("normal", "<leader>=", () => {
  set_ui_scale(get_ui_scale() + UI_SCALE_STEP);
}, { description: "font go big" });

glide.keymaps.set("normal", "<leader>-" as string, () => {
  set_ui_scale(get_ui_scale() - UI_SCALE_STEP);
}, { description: "font go small" });

glide.keymaps.set("normal", "<leader>zz", () => {
  glide.prefs.clear("ui.textScaleFactor");
}, { description: "font go normal" });

function shorten_unique_prefixes(haystack: string[]) {
  // first, construct a set of duplicates
  const seen = new Set();
  const duplicates = new Set();
  for (let t of haystack) {
    if (seen.has(t)) {
      duplicates.add(t);
    } else {
      seen.add(t);
    }
  }

  // shorten each word
  return haystack.map((needle, pos) => {
    if (duplicates.has(needle)) return needle;
    // while all words have the same character at position i, increment i
    for (let i = 1; i <= needle.length; i++) {
      const prefix = needle.slice(0, i);
      const is_unique = haystack.every((w, j) => pos === j || !w.startsWith(prefix));
      if (is_unique) {
        return prefix;
      }
    }
    // no unique prefix
    return needle;
  });
}

function strip(text: string) {
  // strip numbers, non-ascii text, and annoying-to-type characters
  return text.replace(/[0-9]+/g, "").replace(/[^a-zA-Z0-9-]/g, "").toLowerCase();
}

function labels(texts: string[]) {
  // now shorten as much as we can without losing info
  const haystack = shorten_unique_prefixes(texts);

  let nums_used = 0;
  const result = new Array(haystack.length);

  // trim prefixes longer than 3 characters by using letters that occur later in the label.
  // also, try to replace the last letter of duplicates.
  // note that that can only help if the original text was > 3 characters.
  const used = new Set();
  outer: for (const [index, prefix] of haystack.entries()) {
    if (prefix === "") {
      result[index] = String(nums_used++);
    } else if (prefix.length > 3 || used.has(prefix)) {
      const base = prefix.substring(0, 2);
      // try each character after the 3rd in turn.
      // consider the original text, not the shortened prefix.
      for (const c of texts[index]!.substring(2)) {
        const candidate = base + c;
        if (!used.has(candidate)) {
          result[index] = candidate;
          used.add(candidate);
          continue outer;
        }
      }
      // we couldn't shorten it. use a number.
      result[index] = String(nums_used++);
    } else {
      // already short enough, use it as-is.
      result[index] = prefix;
      used.add(prefix);
    }
  }

  // try one last time to shorten prefixes—if we gave up earlier, we might have freed up a spot.
  return shorten_unique_prefixes(result);
}

glide.o.hint_label_generator = async ({ content }) => {
  const texts = await content.map(element => [element.textContent, element.ariaLabel] as const);
  const haystack = texts.map(([text, label]) => strip(text) || strip(label || ""));
  return labels(haystack);
};
