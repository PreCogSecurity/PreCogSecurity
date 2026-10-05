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

  test "rejects a name longer than the column allows" do
    task = Task.new(:name => "x" * (Task::NAME_MAX_LENGTH + 1), :list => lists(:one))
    refute task.valid?
    assert_includes task.errors[:name], "is too long (maximum is #{Task::NAME_MAX_LENGTH} characters)"
  end

  test "accepts a name at exactly the maximum length" do
    task = Task.new(:name => "x" * Task::NAME_MAX_LENGTH, :list => lists(:one))
    assert task.valid?
  end

  test "strips surrounding whitespace from the name" do
    task = Task.create!(:name => "  Padded  ", :list => lists(:one))
    assert_equal "Padded", task.name
  end

  test "rejects a whitespace-only name" do
    task = Task.new(:name => "   ", :list => lists(:one))
    refute task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end
end