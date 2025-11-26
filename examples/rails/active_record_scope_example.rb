# Example ActiveRecord scope
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
end
