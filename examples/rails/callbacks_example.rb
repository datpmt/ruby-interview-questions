# Example of an ActiveRecord callback
class User < ApplicationRecord
  before_save :normalize_name

  private

  def normalize_name
    self.name = name.downcase.titleize
  end
end
