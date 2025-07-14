# frozen_string_literal: true

class Admin::BannersController < Admin::AdminController
  def index
    banners = Banner.all.order(created_at: :desc)
    render json: banners, each_serializer: BannerSerializer
  end

  def show
    banner = Banner.active
    if banner
      render json: banner, serializer: BannerSerializer
    else
      render json: { error: 'No active banner found' }, status: 404
    end
  end

  def create
    banner = Banner.new(banner_params)
    if banner.save
      render json: banner, serializer: BannerSerializer
    else
      render json: { errors: banner.errors.full_messages }, status: 422
    end
  end

  def update
    banner = Banner.find(params[:id])
    if banner.update(banner_params)
      render json: banner, serializer: BannerSerializer
    else
      render json: { errors: banner.errors.full_messages }, status: 422
    end
  end

  def destroy
    banner = Banner.find(params[:id])
    banner.destroy
    render json: success_json
  end

  private

  def banner_params
    params.require(:banner).permit(:announcement, :button_text, :button_link, :active)
  end
end