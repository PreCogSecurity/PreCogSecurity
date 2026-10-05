module TasksHelper
  # Tags permitted in a rendered task name. `auto_link` only ever emits <a>,
  # so anything else is attacker-controlled input reflected back to the browser.
  ALLOWED_LINK_TAGS = %w(a).freeze

  # Attributes permitted on those anchors. `href` is additionally protocol
  # checked by Rails' sanitizer (http/https/mailto only), so `javascript:`
  # payloads are stripped even if they survive auto-linking.
  ALLOWED_LINK_ATTRIBUTES = %w(href title rel target).freeze

  # Attributes forced onto every generated anchor:
  #   noopener    - prevents reverse tabnabbing via window.opener
  #   noreferrer  - withholds the referring URL from the linked site
  #   nofollow    - task names are user content, not endorsements
  SAFE_LINK_ATTRIBUTES = {
    :target => '_blank',
    :rel    => 'nofollow noopener noreferrer'
  }.freeze

  # Human-readable status for a task.
  def task_status(task)
    task.done? ? "Done" : "Pending"
  end

  # Render a task name with any URLs turned into links, safely.
  #
  # Task names are attacker-controlled and are rendered on a page that every
  # visitor loads, so this helper never returns unescaped markup by
  # construction. The pipeline is:
  #
  #   1. h(...)         - escape the stored value, so any '<' in the name is an
  #                      entity and cannot start a tag
  #   2. auto_link(...) - wrap URLs in anchors, with rel/target forced on at
  #                      generation time so a name cannot smuggle its own
  #   3. sanitize(...)  - final allowlist: only <a> survives, only href/title/
  #                      rel/target survive, and only http/https/mailto hrefs
  #
  # The result is an html_safe String, so callers use <%= %> with no `raw`.
  def linked_task_name(task_or_name)
    name = task_or_name.respond_to?(:name) ? task_or_name.name : task_or_name
    html = auto_link(h(name.to_s), :html => SAFE_LINK_ATTRIBUTES)
    sanitize(html, :tags => ALLOWED_LINK_TAGS, :attributes => ALLOWED_LINK_ATTRIBUTES)
  end
end