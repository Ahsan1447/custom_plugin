# frozen_string_literal: true

class Banner < ActiveRecord::Base
  validates :announcement, presence: true
  
  def self.active
    where(active: true).order(created_at: :desc).first
  end
end