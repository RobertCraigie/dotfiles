TL;DR: [Glide](glide-browser.app) is a Firefox fork with a TypeScript [config](https://glide-browser.app/config), aimed at the motivated tinkerer.

##### invisible-heading

[Download](https://glide-browser.app/#download) - [Docs](https://glide-browser.app/) - [Cookbook](https://glide-browser.app/cookbook) - [Source](https://github.com/glide-browser/glide)

---

<br>

Browsers should be hackable, just like your editor.

```typescript
glide.keymaps.set("normal", "gC", async () => {
  // extract the owner and repo from a url like 'https://github.com/glide-browser/glide'
  const [owner, repo] = glide.ctx.url.pathname.split("/").slice(1, 3);
  if (!owner || !repo) throw new Error("current URL is not a github repo");

  // * clone the current github repo to ~/github.com/$owner/$repo
  // * start kitty with neovim open at the cloned repo
  const repo_path = glide.path.join(glide.path.home_dir, "github.com", owner, repo);
  await glide.process.execute("gh", ["repo", "clone", glide.ctx.url, repo_path]);
  await glide.process.execute("kitty", ["-d", repo_path, "nvim"], { cwd: repo_path });
}, { description: "open the GitHub repo in the focused tab in Neovim" });
```

> Example Glide keymapping to clone the GitHub repo in the current tab and open it in [kitty](https://sw.kovidgoyal.net/kitty/) + [neovim](https://neovim.io/).

This snippet captures the customizability I expect from my browser so that I can make my daily workflows a joy.

<!-- TODO: more here? -->

### Why I built Glide

I was using [tridactyl](https://tridactyl.xyz) within Firefox and generally enjoying it, but occasionally I would run into frustrating issues due to security constraints imposed by Firefox on web extensions. For example, extensions are completely disabled on [addons.mozilla.org](https://addons.mozilla.org), so all of my mappings could break depending on the website I had open.

There are also _many_ useful APIs I wanted to use that are not accessible[^1] through tridactyl, such as arbitrary file writes, spawning processes, and setting prefs.

These restrictions are necessary to protect users from extension writers, but what if you wanted to write your own extension for personal use? What's the benefit in restricting what the extension can do then?

That's when I realised that the level of flexibility I desired would never be possible through a web extension.

### How is Glide different?

Glide holistically solves these usability issues by supporting a TypeScript [config](https://glide-browser.app/config) that lets you do _anything_[^2] you'd like to.

You can define custom [key mappings](https://glide-browser.app/keys), access the [web extensions API](https://glide-browser.app/extensions), spawn arbitrary [processes](https://glide-browser.app/api#glide.process), define [macros](https://glide-browser.app/api#glide.keys) and more.

Glide can support APIs and functionality that will never be supported in web extensions as the security model is flipped. You—the end user—are responsible for writing the config code, so there is no reason to restrict what you can do.

Here's a small example that adds <kbd>g</kbd>+<kbd>c</kbd> as a key mapping to switch to the calendar tab:

```typescript
// ~/.config/glide/glide.ts
glide.keymaps.set("normal", "gc", async () => {
  const tab = await glide.tabs.get_first({
    url: "https://calendar.google.com/*",
  });
  assert(tab && tab.id);
  await browser.tabs.update(tab.id, { active: true });
}, {
  description: "[g]o to [c]alendar.google.com",
});
```

For more examples, see the [cookbook](https://glide-browser.app/cookbook) or my own [dotfiles](https://github.com/RobertCraigie/dotfiles/tree/main/glide).

The cherry on top is that all of this is built on _top_ of Firefox, meaning that, if you already use Firefox, then your existing extensions and workflows will still work in Glide.

### Modes

Glide borrows the concept of modes from (neo)vim, every key mapping you define will be attached to a specific mode. Glide will then switch between modes automatically but you can always switch modes manually with custom key mappings.

The default mode is `normal`, where most key mappings are defined. When you click or focus on an input element, Glide will automatically switch to `insert` mode, so that key mappings don't interfere with entering text.

If a website doesn't play well with your key mappings you can switch to `ignore` mode by pressing <kbd>Shift</kbd>+<kbd>Escape</kbd>, in this mode the only default key mapping is <kbd>Shift</kbd>+<kbd>Escape</kbd> to exit ignore mode.

### Navigating

Glide supports a `hint` mode that lets you operate web pages entirely using the keyboard.

Press `f` to enter `hint` mode and Glide will overlay text [labels](https://glide-browser.app/hints#label-generation) over every [hintable](https://glide-browser.app/hints#hintable-elements) element, e.g. links and buttons. Typing the [label](https://glide-browser.app/hints#label-generation) for a hint will then focus and click the element.

See it in action in the [demo video](https://glide-browser.app/#demo-video).

### Personal favourite features

- `gI` focuses the largest visible input element on the page and it feels like magic every time I use it.

- `<space><space>` opens a tab fuzzy finder, which is invaluable for finding that _one_ tab you always lose.

- `<c-i>` and `<c-o>` are also invaluable for navigating previously open tabs.

- `:repl` for quickly testing out config changes.

- [hints](https://glide-browser.app/hints) for when I don't want to reach for my mouse.

- A [which-key](https://github.com/folke/which-key.nvim) inspired UI for reminding you of the many key mappings.

<br>

I've been daily driving Glide for ~6 months now and while I'm biased, I love it. It's still in a very early alpha stage but if you'd like to try it out, you can download it on macOS / Linux [here](https://glide-browser.app/#download). I'd recommend checking out the tutorial with `:tutor` to get some bearings, although it's far from complete yet.

p.s. sorry Linux folks, Glide isn't in any package repositories yet, so you'll have to untar it and add set up Glide manually for now.

<br>

---

[^1]: You can accomplish some things through the [native messenger](https://github.com/tridactyl/tridactyl#extra-features-through-native-messaging).

[^2]: As Glide is in very early alpha there are missing APIs so you can't literally do _everything_ yet, but enabling full control is one of the main goals.
