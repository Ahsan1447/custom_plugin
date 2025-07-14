# frozen_string_literal: true

# name: discourse-education-category-custom-field
# about: Add custom fields to categories for post view, tabs view, and user permissions
# version: 0.2
# author: Angus McLeod

enabled_site_setting :category_custom_field_enabled
register_asset 'stylesheets/common.scss'
register_asset 'stylesheets/banner.scss'
register_asset 'javascripts/discourse/controllers/admin-plugins-banner.js.es6'
register_asset 'javascripts/discourse/routes/admin-plugins-banner.js.es6'
register_asset 'javascripts/discourse/models/banner.js.es6'
register_asset 'javascripts/discourse/widgets/site-banner.js.es6'
register_asset 'javascripts/discourse/initializers/banner-initializer.js.es6'

## 
# type:        introduction
# title:       Add a custom field to a category
# description: To get started, load the [discourse-category-custom-fields](https://github.com/pavilionedu/discourse-category-custom-fields)
#              plugin in your local development environment. Once you've got it
#              working, follow the steps below and in the client "initializer"
#              to understand how it works. For more about the context behind
#              each step, follow the links in the 'references' section.
##

after_initialize do
  # Load banner related files
  load File.expand_path('../app/controllers/admin/banners_controller.rb', __FILE__)
  load File.expand_path('../app/models/banner.rb', __FILE__)
  load File.expand_path('../app/serializers/banner_serializer.rb', __FILE__)
  
  # Mount the banner routes
  Discourse::Application.routes.append do
    mount ::DiscourseEducationCategoryCustomField::Engine, at: "/"
  end

  module ::DiscourseEducationCategoryCustomField
    class Engine < ::Rails::Engine
      engine_name "discourse_education_category_custom_field"
      isolate_namespace DiscourseEducationCategoryCustomField

      config.after_initialize do
        Discourse::Application.routes.append do
          mount ::DiscourseEducationCategoryCustomField::Engine, at: "/"
        end
      end
    end
  end

  require_dependency 'admin_constraint'
  
  # Add banner tab to admin sidebar
  add_admin_route 'banner.title', 'banner'
  
  Discourse::Application.routes.append do
    get '/admin/plugins/banner' => 'admin/plugins#index', constraints: AdminConstraint.new
  end

  # Load banner routes
  require_relative 'lib/banner_route'
  DiscourseEducationCategoryCustomField::BannerRoute.call(Rails.application)

  # Define our custom fields
  CUSTOM_FIELDS = {
    'post_view' => { type: :string, choices: ['grid', 'list'], default: 'list' },
    'tabs_view' => { type: :boolean, default: true },
    'user_can_create_post' => { type: :boolean, default: true },
    'show_main_post' => { type: :boolean, default: false }
  }

  ## 
  # type:        step
  # number:      1
  # title:       Register the field
  # description: Where we tell discourse what kind of field we're adding. You
  #              can register a string, integer, boolean or json field.
  # references:  lib/plugins/instance.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##

  # Register each custom field
  CUSTOM_FIELDS.each do |field_name, config|
    register_category_custom_field_type(field_name, config[:type])
    
    # Add getter method with proper boolean conversion and defaults
    add_to_class(:category, field_name.to_sym) do
      value = custom_fields[field_name]
      if config[:type] == :boolean
        # Convert string boolean to actual boolean, with default fallback
        if value.nil?
          config[:default]
        else
          value == "t" || value == true
        end
      else
        # Return default if value is nil
        value.nil? ? config[:default] : value
      end
    end

    # Add setter method - ensure false values are stored as "f"
    add_to_class(:category, "#{field_name}=") do |value|
      if config[:type] == :boolean
        # Always store boolean values as strings, even when false
        # This ensures false values are preserved and not removed
        custom_fields[field_name] = value ? "t" : "f"
      else
        # For non-boolean fields, store the value as-is
        custom_fields[field_name] = value
      end
    end
  end

  # Simple override to allow false values in custom fields
  CategoriesController.class_eval do
    def update
      guardian.ensure_can_edit!(@category)

      json_result(@category, serializer: CategorySerializer) do |cat|
        old_category_params = category_params.dup

        cat.move_to(category_params[:position].to_i) if category_params[:position]
        category_params.delete(:position)

        old_custom_fields = cat.custom_fields.dup
        if category_params[:custom_fields]
          category_params[:custom_fields].each do |key, value|
            # Allow false values for our custom fields
            if CUSTOM_FIELDS.key?(key)
              cat.custom_fields[key] = value
            else
              # Use original logic for other fields
              if value.present?
                cat.custom_fields[key] = value
              else
                cat.custom_fields.delete(key)
              end
            end
          end
        end
        category_params.delete(:custom_fields)

        # properly null the value so the database constraint doesn't catch us
        category_params[:email_in] = nil if category_params[:email_in]&.blank?
        category_params[:minimum_required_tags] = 0 if category_params[:minimum_required_tags]&.blank?

        old_permissions = cat.permissions_params
        old_permissions = { "everyone" => 1 } if old_permissions.empty?

        if result = cat.update(category_params)
          Scheduler::Defer.later "Log staff action change category settings" do
            @staff_action_logger.log_category_settings_change(
              @category,
              old_category_params,
              old_permissions: old_permissions,
              old_custom_fields: old_custom_fields,
            )
          end
        end

        DiscourseEvent.trigger(:category_updated, cat) if result

        result
      end
    end
  end

  # Set defaults for new categories
  on(:category_created) do |category|
    CUSTOM_FIELDS.each do |field_name, config|
      if category.custom_fields[field_name].nil?
        if config[:type] == :boolean
          category.custom_fields[field_name] = config[:default] ? "t" : "f"
        else
          category.custom_fields[field_name] = config[:default]
        end
        category.save_custom_fields
      end
    end
  end

  # Preload all custom fields
  CUSTOM_FIELDS.keys.each do |field_name|
    Site.preloaded_category_custom_fields << field_name
  end

  ## 
  # type:        step
  # number:      4.2
  # title:       Serialize to the site categories
  # description: In most cases where a category is used, it's taken from a
  #              list of categories sent to the client on the Site model. This
  #              is sent when the Discourse client is first loaded. The
  #              SiteCategorySerializer is also the parent of the more detailed
  #              CategorySerializer which is used to load more attributes in
  #              the category edit interface.
  # references:  lib/plugins/instance.rb,
  #              app/serializers/site_category_serializer.rb,
  #              app/serializers/site_serializer.rb,
  #              app/serializers/category_serializer.rb
  ##
  CUSTOM_FIELDS.keys.each do |field_name|
    add_to_serializer(:site_category, field_name.to_sym) do
      object.send(field_name)
    end
  end
end