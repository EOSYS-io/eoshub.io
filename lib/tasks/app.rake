namespace :app do
  require 'typhoeus'

  desc "Get eos ram price from blockchain and update db."
  task :get_eos_ram_price => :environment do
    # Try calling to several api endpoints of bps.
    Rails.configuration.urls['eos_rpc_urls'].each do |host|
      response = Typhoeus::Request.new(
        host+Rails.configuration.urls['eos_get_table_url'],
        method: :post,
        headers: {'Content-Type'=> "application/json"},
        body: JSON.generate({code: "eosio", scope: "eosio", table: "rammarket", json: true}),
        timeout: 5
      ).run

      if response.code == 200
        # Remove ' EOS'
        response_json = JSON.parse response.body
        denominator = response_json["rows"][0]["base"]["balance"][0...-4].to_f
        # Remove ' RAM'
        numerator = response_json["rows"][0]["quote"]["balance"][0...-4].to_f

        ram_price_per_kb = ((numerator/denominator)*1024).round(8)
        ActiveRecord::Base.connection.execute("SELECT upsert_eos_ram_price_histories('#{Time.now}', #{ram_price_per_kb})")
        break
      end
    end
  end

end
