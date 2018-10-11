class OrdersController < ApplicationController
  include EosAccount

  def request_payment
    request_params = request_payment_params
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(request_params[:eos_account])

    product = Product.find_by(id: request_params[:product_id])
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT unless product.active?
    
    payment_params = {
      client_id: Rails.application.credentials.dig(Rails.env.to_sym, :payletter_client_id),
      user_id: request_params[:eos_account],
      pgcode: request_params[:pgcode],
      order_no: Order.generate_order_no,
      amount: product.price,
      product_name: product.name,
      custom_parameter: request_params[:public_key],
      return_url: orders_path,
      callback_url: payment_results_path
    }

    response = Typhoeus::Request.new(
      Rails.application.credentials.dig(Rails.env.to_sym, :payletter_host) + Rails.configuration.urls['payletter_pay_api_url'],
      method: :post,
      headers: {
        'Content-Type'=> "application/json",
        'Authorization' => "PLKEY #{Rails.application.credentials.dig(Rails.env.to_sym, :payletter_payment_api_key)}"
      },
      body: JSON.generate(payment_params),
      timeout: 3
    ).run

    result = JSON.parse(response.body)
    render json: result, status: response.code
  end

  def create
    @order_params = create_params

    if @order_params&.dig(:cid).present?
      order = Order.create!(
        eos_account: @order_params[:user_id],
        order_no: @order_params[:order_no],
        pgcode: @order_params[:pgcode],
        amount: @order_params[:amount],
        product_name: @order_params[:product_name],
        public_key: @order_params[:custom_parameter],
        account_name: @order_params[:account_name],
        account_no: @order_params[:account_no],
        bank_code: @order_params[:bank_code],
        bank_name: @order_params[:bank_name],
        expire_date: Date.parse(@order_params[:expire_date])
      )

      redirect_to action: 'show', id: order.order_no
    end
  end

  def show
    @order = Order.find_by(order_no: params[:id])
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if @order.blank?
  end

  def create_eos_account
    order = Order.find_by(order_no: params[:id])
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if order.blank?
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_PAID if order.created?
    raise Exceptions::DefaultError, Exceptions::ORDER_ALREADY_DELIVERED if order.delivered?

    eos_account = order.eos_account
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(eos_account)

    response = request_eos_account_creation(eos_account, order.public_key)
    if response.code == 200
      order.delivered!
      render json: { message: I18n.t('users.eos_account_created') }, status: :ok
    elsif response.return_code == :couldnt_connect
      render json: { message: I18n.t('users.eos_wallet_connection_failed')}, status: :internal_server_error
    elsif JSON.parse(response.body).dig('code') == 'ECONNREFUSED'
      render json: { message: I18n.t('users.eos_node_connection_failed') }, status: response.code
    else
      render json: response.body, status: response.code
    end
  end

  private

  def create_params
    params.permit(Order.permit_attributes_on_create)
  end

  def request_payment_params
    product_id, pgcode, eos_account, public_key = params.require([:product_id, :pgcode, :eos_account, :public_key])
    { product_id: product_id, pgcode: pgcode, eos_account: eos_account, public_key: public_key }
  end
end
