class ProductsController < ApplicationController
  def eos_account
    product = Product.where(name: 'eos_account').where(active: true).take
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT if product.blank?

    render json: product, status: :ok
  end
end
