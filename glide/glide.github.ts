/// <reference path="./glide.d.ts" />

glide.autocmds.create("UrlEnter", { hostname: "github.com" }, ({ tab_id }) => {
  if (
    !(glide.ctx.url.includes("/pull/") || glide.ctx.url.includes("/commit/") || glide.ctx.url.includes("/commits/")
      || glide.ctx.url.includes("/compare/"))
  ) {
    return;
  }

  glide.content.execute(create_file_truncate_fixer, { tab_id });
  glide.content.execute(create_marquee_for_truncated_paths, { tab_id });
  glide.content.execute(remove_bad_pulls_ci_button, { tab_id });
});

glide.autocmds.create("UrlEnter", /https:\/\/github\.com\/.*\/.*\/pull\/.*/, ({ tab_id }) => {
  glide.buf.keymaps.set("normal", "<leader>yb", async () => {
    await glide.content.execute(() => {
      const elements = document.querySelectorAll(".js-copy-branch");
      for (const element of elements) {
        if (
          !element.checkVisibility({
            contentVisibilityAuto: true,
            opacityProperty: true,
            visibilityProperty: true,
            checkOpacity: true,
            checkVisibilityCSS: true,
          })
        ) {
          continue;
        }

        (element as HTMLElement).click();
        break;
      }
    }, { tab_id });
  });
});

function create_file_truncate_fixer() {
  fix_truncated_paths();

  const observer = new MutationObserver((mutations) => {
    const has_new_nodes = mutations.some((mutation) => mutation.addedNodes.length > 0);
    if (has_new_nodes) {
      fix_truncated_paths();
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  function fix_truncated_paths() {
    document
      .querySelectorAll("a.Link--primary.Truncate-text[title]")
      .forEach((link) => {
        const full_path = link.getAttribute("title");
        if (!full_path || link.textContent === full_path) {
          // not truncated
          return;
        }

        link.textContent = full_path;
        link.classList.remove("Truncate-text");

        const parent_span = link.closest("span.Truncate");
        if (parent_span) {
          parent_span.classList.remove("Truncate");
        }
      });
  }
}

function create_marquee_for_truncated_paths() {
  add_marquee_to_paths();

  const observer = new MutationObserver((mutations) => {
    const has_new_nodes = mutations.some((mutation) => mutation.addedNodes.length > 0);
    if (has_new_nodes) {
      add_marquee_to_paths();
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  function add_marquee_to_paths() {
    document
      .querySelectorAll<HTMLElement>(`summary[role="button"] a.text-mono.text-small.Link--primary.wb-break-all`)
      .forEach((link) => {
        const link_text = link.textContent;
        if (!link_text || !link_text.startsWith("...")) {
          return;
        }

        if (link.dataset["marquee-applied"]) {
          return;
        }

        link.dataset["marquee-applied"] = "true";

        const wrapper = document.createElement("div");
        wrapper.style.overflow = "hidden";
        wrapper.style.whiteSpace = "nowrap";
        wrapper.style.position = "relative";
        wrapper.style.width = "100%";

        const marquee = document.createElement("div");
        marquee.style.display = "inline-block";
        marquee.style.paddingLeft = "100%";
        marquee.style.animation = "marquee 15s linear infinite";
        marquee.textContent = link_text;

        link.textContent = "";
        link.appendChild(wrapper);
        wrapper.appendChild(marquee);

        if (!document.querySelector("#marquee-styles")) {
          const style = document.createElement("style");
          style.id = "marquee-styles";
          style.textContent = `
          @keyframes marquee {
            0% { transform: translateX(0); }
            100% { transform: translateX(-100%); }
          }
        `;
          document.head.appendChild(style);
        }
      });
  }
}

function remove_bad_pulls_ci_button() {
  delete_pulls_button();

  const observer = new MutationObserver((mutations) => {
    const has_new_nodes = mutations.some((mutation) => mutation.addedNodes.length > 0);
    if (has_new_nodes) {
      delete_pulls_button();
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  function delete_pulls_button() {
    document
      .querySelectorAll(".StatusCheckRowActionBar-module__statusCheckActionBar--Ipu3V")
      .forEach((element) => element.remove());
  }
}

glide.autocmds.create("UrlEnter", { hostname: "github.com" }, ({ tab_id }) => {
  browser.tabs.insertCSS({
    code: css`
      .dropdown-menu-w {
        width: 1000px !important;
        max-width: 1000px !important;
      }
    `,
  });

  glide.buf.keymaps.set("normal", "gm", `hint -s ".js-reviewed-checkbox"`, { description: "file reviewed checkbox" });

  glide.buf.keymaps.set("normal", "gr", async () => {
    glide.hints.show({
      auto_activate: true,
      selector: `[data-disable-with="Resolving conversation…"], [data-disable-with="Unresolving conversation…"]`,
    });
  });

  glide.buf.keymaps.set("normal", "gcd", async () => {
    await glide.content.execute(async () => {
      var close_button: HTMLButtonElement | undefined;
      for (const button of document.querySelectorAll("button")) {
        if (
          button.textContent === "Close issue"
          || button.textContent === "Close with comment"
        ) {
          close_button = button;
          console.log("found!!!!!!!", button);
          break;
        }
      }

      if (!close_button) {
        throw new Error("no button found");
      }

      close_button.click();
    }, { tab_id });
  });

  glide.buf.keymaps.set("normal", "gnp", async () => {
    await glide.content.execute(async () => {
      function find_first<
        Selector extends keyof HTMLElementTagNameMap | (string & {}),
        Element extends HTMLElement = Selector extends keyof HTMLElementTagNameMap ? HTMLElementTagNameMap[Selector]
          : HTMLElement,
      >(props: {
        selector?: Selector;
        predicate?: (element: Element) => boolean;
      }): Element | null {
        for (const element of document.querySelectorAll<Element>(props.selector ?? "*")) {
          if (props.predicate) {
            if (props.predicate(element)) {
              return element;
            }

            continue;
          }
          return element;
        }

        return null;
      }

      const close_button = find_first({
        selector: "button",
        predicate: (element) =>
          element.textContent === "Close issue"
          || element.textContent === "Close with comment",
      });
      if (!close_button) {
        throw new Error("no button found");
      }

      const dropdown = close_button.parentElement!.parentElement!.children[1]!
        .children[0]! as HTMLElement;
      dropdown.click();
      console.log("clicking", dropdown);

      await new Promise((r) => requestAnimationFrame(r));
      await new Promise((r) => requestAnimationFrame(r));
      await new Promise((r) => requestAnimationFrame(r));

      const span = ensure(find_first({
        selector: "span",
        predicate: (element) => element.textContent === "Close as not planned",
      }));
      console.log("clicking", span.parentElement);
      span.parentElement!.click();

      await new Promise((r) => requestAnimationFrame(r));
      await new Promise((r) => requestAnimationFrame(r));
      await new Promise((r) => requestAnimationFrame(r));

      close_button.click();
    }, { tab_id });
  });
});
