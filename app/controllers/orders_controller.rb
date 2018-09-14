class OrdersController < ApiController
  def create
    order_params = order_create_params
    raise Exceptions::DefaultError, Exceptions::MISSING_PARAMETER if order_params.blank?
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if helpers.eos_account_exist?(order_params[:eos_account])

    order_no = Order.generate_order_no
    
    payment_params = {
      pgcode: order_params[:pgcode],
      client_id: Rails.application.credentials.dig(Rails.env.to_sym, :payletter_client_id),
      user_id: order_params[:eos_account],
      order_no: order_no,
      amount: order_params[:amount],
      product_name: order_params[:product_name],
      return_url: '',
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
      timeout: 5
    ).run

    CreateOrderJob.perform_async(
      order_params[:pgcode],
      order_no,
      order_params[:amount],
      order_params[:product_name]
    ) if response.code == 200

    result = JSON.parse(response.body)
    render json: result, status: response.code
  end

  private

  def order_create_params
    params.permit(Order.permit_attributes_on_create)
  end
end
