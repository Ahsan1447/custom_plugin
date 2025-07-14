# frozen_string_literal: true

class BannerSerializer < ApplicationSerializer
  attributes :id, :announcement, :button_text, :button_link, :active, :created_at, :updated_at
end