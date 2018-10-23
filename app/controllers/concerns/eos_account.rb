module EosAccount
  extend ActiveSupport::Concern
  
  def eos_account_exist?(account_name)
    response = Typhoeus::Request.new(
      Rails.application.credentials.dig(Rails.env.to_sym, :eos_wallet_node_host)+Rails.configuration.urls['eos_account_url'],
      method: :get,
      params: { name: account_name },
      timeout: 5
    ).run

    response.code == 200
  end

  def request_eos_account_creation(creator_eos_account, account_name, pubkey)
    eos_account_product = Product.eos_account
    raise Exceptions::DefaultError, Exceptions::PRODUCT_NOT_EXIST if eos_account_product.blank?

    body = {
      creator_eos_account: creator_eos_account, 
      account_name: account_name,
      pubkey: pubkey,
      cpu: eos_account_product.cpu,
      net: eos_account_product.net,
      ram: eos_account_product.ram
    }
    
    response = Typhoeus::Request.new(
      Rails.application.credentials.dig(Rails.env.to_sym, :eos_wallet_node_host)+Rails.configuration.urls['eos_account_url'],
      method: :post,
      headers: {'Content-Type'=> "application/json"},
      body: JSON.generate(body),
      timeout: 5
    ).run

    response
  end
end
