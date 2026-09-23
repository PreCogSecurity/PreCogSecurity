module ListsHelper
  # Display name for a list. Mirrors the capitalization applied in the index
  # view, but tolerates a nil name instead of raising.
  def list_name(list)
    list.name.to_s.capitalize
  end
end