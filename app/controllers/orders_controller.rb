class OrdersController < ApplicationController
  include EosAccount

  def request_payment
    raise Exceptions::DefaultError, Exceptions::MISSING_PARAMETER if params.blank?
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(params[:eos_account])

    order_no = Order.generate_order_no
    
    payment_params = {
      pgcode: params[:pgcode],
      client_id: Rails.application.credentials.dig(Rails.env.to_sym, :payletter_client_id),
      user_id: params[:eos_account],
      order_no: order_no,
      amount: params[:amount],
      product_name: params[:product_name],
      return_url: orders_path,
      # TODO(sinhyeok): 가상계좌 입금완료 후 호출될 payment_result api 구현 후 연결
      callback_url: ''
    }

    response = Typhoeus::Request.new(
      Rails.configuration.urls['payletter_host'] + Rails.configuration.urls['payletter_pay_api_url'],
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
    order_params = order_create_params

    if order_params&.dig(:cid).present?
      Order.create!({
        user_id: order_params[:user_id],
        pgcode: order_params[:pgcode],
        order_no: order_no,
        amount: order_params[:amount],
        product_name: order_params[:product_name],
        account_name: order_params[:account_name],
        account_no: order_params[:account_no],
        bank_code: order_params[:bank_code],
        bank_name: order_params[:bank_name],
        expire_date: order_params[:expire_date]
      })
  
      #TODO(sinhyeok): 가상계좌 발급완료 페이지 구현 후 연결
      redirect_to "https://eosys.io"
    else
      #TODO(sinhyeok): 가상계좌 발급완료 페이지 구현 후 연결
      redirect_to "https://eosys.io"
    end
  end

  private

  def order_create_params
    params.permit(Order.permit_attributes_on_create)
  end
end
