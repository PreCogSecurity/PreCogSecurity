require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  test "is valid with a name and a list" do
    assert Task.new(:name => "Buy milk", :list => lists(:one)).valid?
  end

  test "is invalid without a name" do
    task = Task.new(:name => nil, :list => lists(:one))
    refute task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end

  test "belongs to a list" do
    assert_equal lists(:one), tasks(:one).list
  end

  test "done is falsy by default" do
    task = Task.create!(:name => "Fresh task", :list => lists(:one))
    refute task.done
  end
end