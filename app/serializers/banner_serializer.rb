# frozen_string_literal: true

class BannerSerializer < ApplicationSerializer
  attributes :id, :title, :button_text, :button_link, :active, :created_at, :updated_at
end