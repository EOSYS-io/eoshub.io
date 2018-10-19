class ProductsController < ApplicationController
  def eos_account
    eos_account_product = Product.eos_account
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT if eos_account_product.blank?

    render json: eos_account_product, status: :ok
  end
end
