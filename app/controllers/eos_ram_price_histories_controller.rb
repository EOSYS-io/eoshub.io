class EosRamPriceHistoriesController < ApiController
  def data
    unless PriceHistoryIntvl.find_by(seconds: params[:intvl]).present?
      render json: { msg: I18n.t('eos_ram_price_histores.unsupported_interval') }, status: :bad_request and return
    end

    price_histories = EosRamPriceHistory.where(
      intvl: params[:intvl],
      start_time: (Time.at(params[:from].to_i).to_datetime)..(Time.at(params[:to].to_i).to_datetime)
    )
    
    render json: price_histories
  end
end
