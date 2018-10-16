class PaymentResultsController < ApiController
  def create
    @payment_result_params = create_params

    order = Order.find_by(order_no: params[:order_no])
    if params.dig(:cid).present? || params.dig(:issue_tid).present?
      order.paid!

      PaymentResult.create!(
        order: order,
        cid: @payment_result_params[:cid],
        tid: @payment_result_params[:tid],
        pay_info: @payment_result_params[:pay_info],
        transaction_date: DateTime.parse(@payment_result_params[:transaction_date]),
        code: @payment_result_params[:code],
        message: @payment_result_params[:message],
      )
    else
      PaymentResult.create!(
        order: order,
        code: @payment_result_params[:code],
        message: @payment_result_params[:message],
      )
    end

    render json: { code: 0 }, status: :ok
  end

  private 

  def create_params
    params.permit(PaymentResult.permit_attributes_on_create)
  end
end
