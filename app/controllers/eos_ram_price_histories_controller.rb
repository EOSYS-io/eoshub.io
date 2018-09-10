class EosRamPriceHistoriesController < ApiController
  def data
    unless PriceHistoryIntvl.exists?(seconds: params[:intvl])
      render json: { msg: I18n.t('eos_ram_price_histores.unsupported_interval') }, status: :bad_request and return
    end

    price_histories = EosRamPriceHistory.where(
      intvl: params[:intvl],
      start_time: (Time.at(params[:from].to_i).to_datetime)..(Time.at(params[:to].to_i).to_datetime)
    ).order(:start_time)
    
    render json: price_histories
  end
end
