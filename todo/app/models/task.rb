class Task < ActiveRecord::Base
  # Matches the width of the underlying `string` column. Without an explicit
  # bound, `name` accepted arbitrarily long user input: a single request could
  # store an unbounded blob (storage abuse / cheap denial of service), and every
  # page that renders the task would then re-read and re-render it.
  NAME_MAX_LENGTH = 255

  belongs_to :list, class_name: "List", foreign_key: "list_id"

  # Normalise surrounding whitespace before validation so "  Milk" and "Milk"
  # are stored (and later compared) as the same value.
  before_validation :normalize_name

  validates :name, :presence => true, :length => { :maximum => NAME_MAX_LENGTH }

  private

  def normalize_name
    self.name = name.strip if name.is_a?(String)
  end
end