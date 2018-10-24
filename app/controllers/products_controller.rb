class ProductsController < ApplicationController
  include EosAccount

  before_action :check_event_balance

  def eos_account
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT if @eos_account_product.blank?

    render json: eos_account_product, status: :ok
  end 

  private

  def check_event_balance
    @eos_account_product = Product.eos_account
    creator_eos_account = @eos_account_product.creator_event
    balance = core_liquid_balance(creator_eos_account)
    if balance < 1
      @eos_account_product.update(event_activation: false) if @eos_account_product.event_activation
    end
  end
end
