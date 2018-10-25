class OrdersController < ApplicationController
  include EosAccount

  skip_before_action :verify_authenticity_token, if: -> { 
    controller_name == 'orders' && ['request_payment','create','create_eos_account'].include?(action_name)
  }

  def request_payment
    request_params = request_payment_params
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(request_params[:eos_account])

    product = Product.find_by(id: request_params[:product_id])
    raise Exceptions::DefaultError, Exceptions::DEACTIVATED_PRODUCT unless product.active?
    
    order = Order.create!(
      eos_account: request_params[:eos_account],
      pgcode: request_params[:pgcode],
      amount: product.price,
      product_name: product.name,
      public_key: request_params[:public_key]
    )

    payment_params = {
      client_id: Rails.application.credentials.dig(Rails.env.to_sym, :payletter_client_id),
      service_name: 'eoshub.io',
      user_id: order.eos_account,
      user_name: order.eos_account,
      pgcode: order.pgcode,
      order_no: order.order_no,
      amount: product.price,
      product_name: product.name,
      custom_parameter: order.public_key
    }
    # for local test, pg company do not accept localhost url
    if Rails.env.development?
      payment_params.merge!(
        return_url: 'http://alpha.eoshub.io/orders',
        callback_url: 'http://alpha.eoshub.io/payment_results'
      )
    else
      payment_params.merge!(
        return_url: orders_url,
        callback_url: payment_results_url
      )
    end

    response = Typhoeus::Request.new(
      Rails.application.credentials.dig(Rails.env.to_sym, :payletter_host) + Rails.configuration.urls['payletter_pay_api_url'],
      method: :post,
      headers: {
        'Content-Type'=> "application/json",
        'Authorization' => "PLKEY #{Rails.application.credentials.dig(Rails.env.to_sym, :payletter_payment_api_key)}"
      },
      body: JSON.generate(payment_params),
      timeout: 5
    ).run

    raise Exceptions::DefaultError, Exceptions::PAYMENT_SERVER_NOT_RESPOND if response.return_code == :operation_timedout

    result = JSON.parse(response.body).merge(order_no: order.order_no)
    if Rails.env.development?
      result[:online_url] = order_url(id: order.order_no)
    end

    render json: result, status: response.code
  end

  def create
    @order_params = create_params
    order = Order.find_by(order_no: @order_params[:order_no])

    if params.dig(:cid).present? || params.dig(:issue_tid).present?
      order.update!(
        account_name: @order_params[:account_name],
        account_no: @order_params[:account_no],
        bank_code: @order_params[:bank_code],
        bank_name: @order_params[:bank_name],
        expire_date: Date.parse(@order_params[:expire_date]),
        tid: @order_params[:tid] || @order_params[:issue_tid],
        return_code: @order_params[:code],
        return_message: @order_params[:message]
      )

      redirect_to action: 'show', id: order.order_no
    else
      order.update!(
        return_code: @order_params[:code],
        return_message: @order_params[:message]
      )

      redirect_to action: 'show_error', id: order.order_no
    end
  end

  def show
    @order = Order.find_by(order_no: params[:id])
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if @order.blank?
  end

  def show_error
    @order = Order.find_by(order_no: params[:id])
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if @order.blank?
  end

  def check_eos_account_created
    order = Order.find_by(order_no: params[:id])
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if order.blank?

    if order.delivered?
      eos_account = order.eos_account
      if eos_account_exist?(eos_account)
        render json: { eos_account: eos_account, public_key: order.public_key }, status: :ok
      else
        render json: { message: I18n.t('orders.order_delivered_but_eos_account_not_exist') }, status: :internal_server_error
      end
    elsif order.created?
      render json: { message: I18n.t('orders.order_not_paid') }, status: :bad_request
    elsif order.paid?
      render json: { message: I18n.t('orders.order_paid_eos_account_creation_progressing') }, status: :bad_request
    elsif order.delivery_failed?
      render json: { message: I18n.t('orders.order_delivery_failed') }, status: :internal_server_error
    else
      # Unreachable
      render json: { message: I18n.t('errors.unexpected_error') }, status: :internal_server_error
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
