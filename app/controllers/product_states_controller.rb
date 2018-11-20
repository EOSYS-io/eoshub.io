class ProductStatesController < ApplicationController
  def index
    announcements = Announcement.where('active = true AND published_at <= NOW() AND ended_at >= NOW()').order("published_at DESC").limit(1);
    settings= Setting.order("created_at DESC").limit(1);
    render json: {status: 'SUCCESS', data:{announcements:announcements, settings:settings}}, status: :ok
  end
end