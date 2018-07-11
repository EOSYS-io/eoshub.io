module UsersHelper
  def eos_account_exist?(account_name)
    response = Typhoeus::Request.new(
      Rails.configuration.urls['eos_wallet_node_host']+Rails.configuration.urls['eos_account_url'],
      method: :get,
      params: { name: account_name }
    ).run

    response.code == 200
  end

  def create_eos_account(account_name, pubkey)
    response = Typhoeus::Request.new(
      Rails.configuration.urls['eos_wallet_node_host']+Rails.configuration.urls['eos_account_url'],
      method: :post,
      headers: {'Content-Type'=> "application/json"},
      body: JSON.generate({account_name: account_name, pubkey: pubkey})
    ).run

    response
  end
end
