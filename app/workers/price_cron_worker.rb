class PriceCronWorker
  include Sidekiq::Worker

  def perform(*args)
    expiry_time = Time.now + 59.9
    while (Time.now < expiry_time)
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
          EosRamPriceHistory.upsert_eos_ram_price_histories(ram_price_per_kb)
          break
        end
      end
      # Sleep for eos block interval + network delay.
      sleep 0.45
    end
  end
end
