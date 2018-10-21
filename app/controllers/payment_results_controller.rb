class PaymentResultsController < ApiController
  def create
    @pr_params = create_params

    order = Order.find_by(order_no: params[:order_no])
    if params.dig(:cid).present? || params.dig(:issue_tid).present?
      validation_hash = sha256_hash(@pr_params[:user_id], @pr_params[:amount], @pr_params[:tid])
      raise Exceptions::DefaultError, Exceptions::INVALID_PAYMENT_RESULT_CALLBACK if validation_hash != @pr_params[:payhash]
      
      order.paid!

      PaymentResult.create!(
        user_id: @pr_params[:user_id],
        amount: @pr_params[:amount],
        order: order,
        cid: @pr_params[:cid],
        tid: @pr_params[:tid],
        pay_info: @pr_params[:pay_info],
        transaction_date: Time.zone.parse(@pr_params[:transaction_date]),
        payhash: @pr_params[:payhash],
        code: @pr_params[:code],
        message: @pr_params[:message],
      )
    else
      PaymentResult.create!(
        order: order,
        code: @pr_params[:code],
        message: @pr_params[:message],
      )
    end

    render json: { code: 0 }, status: :ok
  end

  def sha256_hash(user_id, amount, tid)
    payment_api_key = Rails.application.credentials.dig(Rails.env.to_sym, :payletter_payment_api_key)
    validation_value = "#{user_id}#{amount}#{tid}#{payment_api_key}"
    Digest::SHA256.hexdigest(validation_value).upcase
  end

  private 

  def create_params
    params.permit(PaymentResult.permit_attributes_on_create)
  end
end
