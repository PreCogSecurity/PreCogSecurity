class List < ActiveRecord::Base
  # Matches the width of the underlying `string` column; see Task::NAME_MAX_LENGTH.
  NAME_MAX_LENGTH = 255

  # Normalise surrounding whitespace before validation. Without this,
  # uniqueness was trivially bypassable with "Errands " vs "Errands".
  before_validation :normalize_name

  validates :name, :presence => true, :length => { :maximum => NAME_MAX_LENGTH }
  validates_uniqueness_of :name, on: :create, message: "must be unique"

  has_many :tasks , dependent: :destroy

  def done_tasks
     tasks.where(done: true).order("updated_at DESC")
  end

  private

  def normalize_name
    self.name = name.strip if name.is_a?(String)
  end
end