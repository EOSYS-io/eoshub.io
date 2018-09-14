class CreateOrderJob < ApplicationJob
  def perform(pgcode, order_no, amount, product_name)
    Order.create!({
      pgcode: pgcode,
      order_no: order_no,
      amount: amount,
      product_name: product_name
    })
  end
end