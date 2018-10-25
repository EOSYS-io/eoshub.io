class CreateEosAccountJob < ApplicationJob
  sidekiq_options retry: 1

  def perform(order_no)
    order = Order.find_by(order_no: order_no)
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_EXIST if order.blank?
    raise Exceptions::DefaultError, Exceptions::ORDER_NOT_PAID if order.created?
    raise Exceptions::DefaultError, Exceptions::ORDER_ALREADY_DELIVERED if order.delivered?

    public_key = order.public_key
    eos_account = order.eos_account
    raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(eos_account)

    creator_eos_account = Product.eos_account.creator_order
    response = request_eos_account_creation(creator_eos_account, eos_account, public_key)
    if response.code == 200
      order.delivered!
    else
      message = { body: response.body, code: response.code, return_code: response.return_code}
      order.delivery_message = message
      order.delivery_failed!
    end
  rescue e =>
    order.delivery_message = e.as_json
    if order.paid?
      order.delivery_failed! 
    else
      order.save!
    end
  end
end