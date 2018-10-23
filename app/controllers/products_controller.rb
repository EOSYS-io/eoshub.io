class ProductsController < ApplicationController
  include EosAccount

  before_action :checkEventBalance

  def eos_account
    eos_account_product = Product.eos_account
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT if eos_account_product.blank?

    render json: eos_account_product, status: :ok
  end 

  private

  def check_event_balance
    eos_account = Rails.application.credentials.dig(:creator_eos_account_event)
    balance = core_liquid_balance(eos_account)
    if balance < 1
      Product.eos_account.update(event_activation: false)
    end
  end
end
