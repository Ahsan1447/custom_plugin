# frozen_string_literal: true

module DiscourseEducationCategoryCustomField
  class BannerRoute
    def self.call(app, _opts = {})
      app.routes.append do
        # Admin routes for managing banners
        namespace :admin, constraints: StaffConstraint.new do
          resources :banners, only: [:index, :show, :create, :update, :destroy]
        end

        # Public API endpoint to get the active banner
        get '/banner' => 'admin/banners#show'
      end
    end
  end
end