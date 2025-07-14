# frozen_string_literal: true

class CreateBanners < ActiveRecord::Migration[6.0]
  def change
    create_table :banners do |t|
      t.string :announcement, null: false
      t.string :button_text
      t.string :button_link
      t.boolean :active, default: true

      t.timestamps
    end
  end
end