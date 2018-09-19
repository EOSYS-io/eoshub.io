class PaymentResultsController < ApiController
  def create
    @payment_result_params = create_params

    if @payment_result_params&.dig(:cid).present?
      order = Order.find_by(order_no: params[:order_no])
      order.paid!

      PaymentResult.create!(
        order: order,
        cid: @payment_result_params[:cid],
        tid: @payment_result_params[:tid],
        pay_info: @payment_result_params[:pay_info],
        transaction_date: DateTime.parse(@payment_result_params[:transaction_date])
      )
    end

    render json: { code: 0 }, status: :ok
  end

  private 

  def create_params
    params.permit(PaymentResult.permit_attributes_on_create)
  end
end
