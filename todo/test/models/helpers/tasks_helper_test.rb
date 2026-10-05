require 'test_helper'

class TasksHelperTest < ActionView::TestCase
  # Exercise the helper through the view context, which is exactly how it is
  # invoked from a template. That matters: `auto_link` is injected into
  # ActionView::Base by the rails_autolink engine, so calling the helper on the
  # test instance directly would not reflect how it resolves at runtime.
  def render_task_name(name)
    view.linked_task_name(name)
  end

  # Parse rendered markup so assertions are made about the DOM that actually
  # reaches the browser, rather than about substrings of escaped text (which
  # look like tags but are not).
  def fragment(html)
    Nokogiri::HTML.fragment(html)
  end

  test "task_status returns Done for completed tasks" do
    task = tasks(:one)
    task.update_column(:done, true)
    assert_equal "Done", task_status(task)
  end

  test "task_status returns Pending for open tasks" do
    assert_equal "Pending", task_status(tasks(:one))
  end

  # --- linked_task_name: XSS and reverse-tabnabbing hardening ---------------

  test "linked_task_name renders plain text unchanged" do
    assert_equal "Buy milk", render_task_name("Buy milk")
  end

  test "linked_task_name accepts a task record" do
    assert_equal tasks(:one).name, render_task_name(tasks(:one))
  end

  test "linked_task_name tolerates a nil name" do
    assert_equal "", render_task_name(List.new(:name => nil))
  end

  test "linked_task_name never emits an element other than an anchor" do
    payload = %q{<script>alert(1)</script><img src=x onerror=alert(1)>}
    tags = fragment(render_task_name(payload)).css('*').map(&:name).uniq
    assert_equal [], tags - %w(a)
  end

  test "linked_task_name escapes an embedded script tag" do
    doc = fragment(render_task_name(%q{<script>alert(1)</script>}))
    assert_equal 0, doc.css('script').length
    assert_equal 1, doc.text.scan('alert(1)').length
  end

  test "linked_task_name escapes an injected img tag and its event handler" do
    doc = fragment(render_task_name(%q{<img src=x onerror=alert(1)>}))
    assert_equal 0, doc.css('img').length
    assert_equal 0, doc.css('[onerror]').length
  end

  test "linked_task_name does not linkify a javascript: URL" do
    doc = fragment(render_task_name("click javascript:alert(1)"))
    assert_equal 0, doc.css('a').length
  end

  test "linked_task_name strips elements outside the link allowlist" do
    payload = "<b>bold</b> <iframe src='http://evil.test'></iframe> <h1>x</h1>"
    doc = fragment(render_task_name(payload))
    assert_equal 0, doc.css('iframe, b, h1').length
  end

  test "linked_task_name links a plain http URL" do
    doc = fragment(render_task_name("see http://example.com/docs for details"))
    assert_equal 1, doc.css('a').length
    assert_equal "http://example.com/docs", doc.css('a').first['href']
  end

  test "linked_task_name forces rel and target on generated links" do
    doc = fragment(render_task_name("http://example.com/docs"))
    anchor = doc.css('a').first
    assert_not_nil anchor
    assert_equal %w(nofollow noopener noreferrer), anchor['rel'].to_s.split.sort
    assert_equal "_blank", anchor['target']
  end

  test "linked_task_name does not let the task name choose its own rel" do
    doc = fragment(render_task_name(%q{<a rel="opener">http://example.com</a>}))
    doc.css('a').each do |anchor|
      assert_includes anchor['rel'].to_s, 'noopener'
      refute_equal 'opener', anchor['rel']
    end
  end

  test "linked_task_name result is html_safe so callers need no raw" do
    assert render_task_name("Buy milk").html_safe?
  end
end