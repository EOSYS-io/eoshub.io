namespace :app do
  require 'typhoeus'

  desc "Get eos ram price from blockchain and update db."
  task :get_eos_ram_price do
    Rails.configuration.urls['eos_rpc_urls'].each do |host|
      response = Typhoeus::Request.new(
        host+Rails.configuration.urls['eos_get_table_url'],
        method: :post,
        headers: {'Content-Type'=> "application/json"},
        body: JSON.generate({code: "eosio", scope: "eosio", table: "rammarket", json: true}),
        timeout: 5
      ).run
      if response.code == 200
        puts response.body
        break
      end
    end
  end

end
