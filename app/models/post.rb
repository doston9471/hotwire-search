class Post < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["title", "description", "body"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
