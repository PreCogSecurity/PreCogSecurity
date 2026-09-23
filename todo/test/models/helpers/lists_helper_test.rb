require 'test_helper'

class ListsHelperTest < ActionView::TestCase
  test "list_name capitalizes the list name" do
    assert_equal "Listone", list_name(lists(:one))
  end

  test "list_name tolerates a nil name" do
    assert_equal "", list_name(List.new(:name => nil))
  end
end