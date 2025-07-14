# frozen_string_literal: true

class RenameAnnouncementToTitleInBanners < ActiveRecord::Migration[6.0]
  def change
    rename_column :banners, :announcement, :title
  end
end 