// keymapping to start automatically updating a draft blog post on a bearblog site
// assumes a tab is open with the post editor and that the current tab is the draft preview

const local_blog_path = glide.path.join(glide.path.home_dir, "code", "glide-browser", "blog.md");
var proc: glide.Process | null = null;

glide.autocmds.create("UrlEnter", /https:\/\/blog\.craigie\.dev\/.*\?token\=.*/, () => {
  glide.buf.keymaps.set("normal", "<leader>r", async ({ tab_id }) => {
    const tab = ensure(
      await glide.tabs.get_first({ url: "https://bearblog.dev/craigie/dashboard/posts/*" }),
      "could not find a bearblog post edit tab",
    );

    if (proc) {
      await proc.kill();
    }

    proc = await glide.process.spawn("/Users/robert/.local/bin/uvx", ["watchfiles", "echo", local_blog_path]);

    try {
      for await (const _ of proc.stdout) {
        const content = await glide.fs.read(local_blog_path, "utf8");

        await glide.content.execute(({ content }) => {
          const textarea = document.getElementById("body_content")! as HTMLTextAreaElement;
          textarea.value = content;

          for (var button of document.querySelectorAll("button")) {
            if (button.textContent?.trim() === "Save as draft") {
              button.click();
              break;
            }
          }
        }, { tab_id: tab.id!, args: [{ content }] });

        await browser.tabs.reload(tab_id);
      }
    } finally {
      proc.kill();
    }
  });

  glide.buf.keymaps.set("normal", "<leader>k", async () => {
    if (proc) {
      await proc.kill();
    }
  });
});
