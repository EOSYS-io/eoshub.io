class ProducersController < ApplicationController
  def index
    render json: Producer.order(:rank)
  end
end
