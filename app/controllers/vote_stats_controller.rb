class VoteStatsController < ApiController
  def recent_stat
    unless VoteStat.exists?
      render json: { msg: I18n.t('vote_stats.not_found') }, status: :not_found and return
    end

    render json: VoteStat.order(:created_at).last
  end
end
