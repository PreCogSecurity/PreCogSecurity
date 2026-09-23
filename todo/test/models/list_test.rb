require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test "is valid with a name" do
    assert List.new(:name => "Errands").valid?
  end

  test "is invalid without a name" do
    list = List.new(:name => nil)
    refute list.valid?
    assert_includes list.errors[:name], "can't be blank"
  end

  test "name must be unique on create" do
    duplicate = List.new(:name => lists(:one).name)
    refute duplicate.valid?
    assert_includes duplicate.errors[:name], "must be unique"
  end

  test "destroying a list destroys its tasks" do
    list = lists(:one)
    assert_difference('Task.count', -list.tasks.count) do
      list.destroy
    end
  end

  test "done_tasks returns only completed tasks, newest first" do
    list = lists(:one)
    older = Task.create!(:name => "Older done", :done => true, :list => list)
    older.update_column(:updated_at, 2.days.ago)
    newer = Task.create!(:name => "Newer done", :done => true, :list => list)
    newer.update_column(:updated_at, 1.day.ago)
    Task.create!(:name => "Still pending", :done => false, :list => list)

    assert_equal [newer, older], list.done_tasks.to_a
  end
end