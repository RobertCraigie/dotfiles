glide.autocmds.create("UrlEnter", { hostname: "app.slack.com" }, ({ tab_id }) => {
  glide.content.execute(create_slack_summarize_deleter, { tab_id });
});

function create_slack_summarize_deleter() {
  delete_slack_summary_buttons();

  const observer = new MutationObserver((mutations) => {
    const has_new_nodes = mutations.some((mutation) => mutation.addedNodes.length > 0);
    if (has_new_nodes) {
      delete_slack_summary_buttons();
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  function delete_slack_summary_buttons() {
    document
      .querySelectorAll(
        "[data-qa=\"summarize-wrapper\"], [aria-label=\"Summarize thread\"], [aria-label=\"Summarize channel\"]",
      )
      .forEach((element) => element.remove());
  }
}

