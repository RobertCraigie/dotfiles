TLDR; [Glide](glide-browser.app) is a Firefox-based, [modal](#modes), and [malleable](https://glide-browser.app/config)[^1] web browser for the motivated tinkerer.

##### invisible-heading

[Download](https://glide-browser.app/#download) - [Docs](https://glide-browser.app/) - [Cookbook](https://glide-browser.app/cookbook) - [Source](https://github.com/glide-browser/glide)

---

<br>

I believe browsers should be hackable, just like your editor.

```typescript
glide.keymaps.set("normal", "gC", async () => {
  // extract the owner and repo from a url like 'https://github.com/glide-browser/glide'
  const [owner, repo] = glide.ctx.url.pathname.split("/").slice(1, 3);
  if (!owner || !repo) throw new Error("current URL is not a github repo");

  // * clone the current github repo to ~/github.com/$owner/$repo
  // * start kitty with neovim open at the cloned repo
  const repo_path = glide.path.join(glide.path.home_dir, "github.com", owner, repo);
  await glide.process.execute("gh", [ "repo", "clone", glide.ctx.url, repo_path]);
  await glide.process.execute("kitty", ["-d", repo_path, "nvim"], { cwd: repo_path });
}, { description: "open the GitHub repo in the focused tab in Neovim" });
```

> Example Glide keymapping to clone the GitHub repo in the current tab and open it in [Kitty](https://sw.kovidgoyal.net/kitty/) + [Neovim](https://neovim.io/).

This snippet captures exactly the kind of functionality I personally want from a browser; extreme customisability so that I can make my daily workflows a joy.

### What's wrong with the status quo?

Most browsers only allow you to customise shortcuts for certain predefined actions, and do not allow you to define your own entirely custom keymappings without going through a web extension; and even then support for writing your own code is very limited.

Existing web extensions[^2] do offer similar functionality to Glide but are artificially restricted in scope by security constraints[^3] imposed on all web extensions.

For example, extensions are completely disabled on certain URIs, e.g. [addons.mozilla.org](https://addons.mozilla.org), the json file viewer, etc. Which means that relying on extension defined mappings on those pages will not work.

There are also *many* useful APIs that are not provided to web extensions, such as arbitrary file writes, spawning processes, and setting prefs.

### How is Glide different?

Glide holistically solves these usability issues by introducing [modes](#modes), and a TypeScript [config](https://glide-browser.app/config) that lets you do _anything_[^4] you'd like to.

You can define custom [key mappings](https://glide-browser.app/keys), access the [web extensions API](https://glide-browser.app/extensions), spawn arbitrary [processes](https://glide-browser.app/api#glide.process), define [macros](https://glide-browser.app/api#glide.keys) and more.

Glide can support APIs and functionality that will never be supported in web extensions as the security model is flipped. You - the end user - are responsible for writing the config code, so there is no reason to restrict what you can do.

Here's a small example that adds g + c as a key mapping to switch to the calendar tab:

```typescript
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

If a website doesn't play well with your key mappings you can switch to `ignore` mode by holding Shift and pressing Escape, in this mode the only default key mapping is Shift + Escape to exit ignore mode.

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

I've been daily driving Glide for ~6 months now and while I'm biased, I love it. It's still in a very early alpha stage but if you'd like to try it out, you can download it on macOS / Linux [here](https://glide-browser.app/#download). I'd recommend checking out the tutorial with `:tutor` to get some bearings, although it's not fully complete yet.

p.s. sorry Linux folks, Glide isn't in any package repositories yet, so you'll have to untar it and add set up Glide manually for now.

<br>

---

[^1]: Glide doesn't try to accomplish all the goals outlined in this [Ink & Switch essay](https://www.inkandswitch.com/essay/malleable-software/), but it is heavily inspired by the same philosophy.

[^2]: Some of Glides main inspirations are [tridactyl](https://tridactyl.xyz/) and [vimium](https://vimium.github.io/).

[^3]: Note that I do think the web extensions security constraints are reasonable in that context. e.g. you wouldn't want want a malicious extension to run on addons.mozilla.org and prevent itself from being uninstalled.

[^4]: As Glide is in very early alpha there are missing APIs so you can't literally do _everything_ yet, but enabling full control is one of the main goals.

<!-- ### How is Glide different? -->
<!---->
<!-- Foo -->

<!-- So, what's lacking from current mainstream browsers? -->

<!-- I want to be able to do *anything* I'd like, not just be limited to the security restrictions imposed on the Web Extensions APIs. -->
<!---->
<!-- ---- -->
<!---->
<!-- So, what are current mainstream browsers lacking in this area? -->
<!---->
<!-- Web extensions let you accomplish a *lot*  -->


<!-- I should be able to deeply integrate it with the rest of my system, instead of the walled garden it is today. -->

<!-- For a long time I've been frustrated by the extensibility of web browsers. I want the software I use the most to be [malleable](https://www.inkandswitch.com/malleable-software/) to my preferences so that it is a _joy_ to use. -->

<!-- <br> -->
<!-- <br> -->
<!-- <br> -->
<!-- <br> -->
<!-- <br> -->
<!---->
<!---->
<!-- One of the main aspects of the browser that I want to configure is key mappings, so that it can be pleasant to mostly operate using just my keyboard. I started off using [Tridactyl](https://github.com/tridactyl/tridactyl) as my daily driver for a while and it was generally very good, however I ran into many minor annoyances due to restrictions that Firefox imposes on extensions. -->
<!---->
<!-- For example, extensions are completely disabled on certain URIs, e.g. [addons.mozilla.org](https://addons.mozilla.org), the json file viewer, etc. Which meant that using Tridactyl mappings to scroll through my open tabs would stop working if any of the tabs I had open were restricted. -->
<!---->
<!-- There generally are workarounds for these issues, however having to fight against my browser to get this to work didn't seem particularly appealing to me. -->
<!---->
<!-- --- -->
