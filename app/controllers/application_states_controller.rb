class ApplicationStatesController < ApplicationController
  def index
    announcement = Announcement.where('active = true AND published_at <= NOW() AND ended_at >= NOW()').order("published_at DESC").take;
    setting= Setting.order("created_at DESC").take;
    render json: {status: 'SUCCESS', data:{announcement:announcement, setting:setting}}, status: :ok
  end
end