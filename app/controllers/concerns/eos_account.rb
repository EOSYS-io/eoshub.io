module EosAccount
  extend ActiveSupport::Concern
  
  def eos_account_exist?(account_name)
    response = Typhoeus::Request.new(
      Rails.configuration.urls['eos_wallet_node_host']+Rails.configuration.urls['eos_account_url'],
      method: :get,
      params: { name: account_name },
      timeout: 5
    ).run

    response.code == 200
  end

  def request_eos_account_creation(account_name, pubkey)
    response = Typhoeus::Request.new(
      Rails.configuration.urls['eos_wallet_node_host']+Rails.configuration.urls['eos_account_url'],
      method: :post,
      headers: {'Content-Type'=> "application/json"},
      body: JSON.generate({account_name: account_name, pubkey: pubkey}),
      timeout: 5
    ).run

    response
  end
end
