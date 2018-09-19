class ProducerCronWorker
  include EosRamPriceHistoriesHelper
  include Sidekiq::Worker

  def perform(*args)
    # From experiments, eosio table request returns up to 2500 rows.
    body = {
      code: "eosio",
      scope: "eosio",
      table: "producers",
      json: true,
      limit: 2500
    }
    response = nil
    Rails.configuration.urls['eos_rpc_urls'].each do |host|
      response = Typhoeus::Request.new(
        host+Rails.configuration.urls['eos_get_table_url'],
        method: :post,
        headers: {'Content-Type'=> "application/json"},
        body: JSON.generate(body),
        timeout: 5
      ).run
      if response.code == 200
        break
      end
    end

    # All request fail.
    if response.code != 200
      return
    end

    response_json = JSON.parse response.body
    rows = response_json["rows"].sort_by{ |row| row["total_votes"].to_f }.reverse

    rows.each_with_index do |row, index|
      country = ""
      is_active = row["is_active"] == 1 ? true : false
      last_claim_time = row["last_claim_time"] == 0 ? "" : row["last_claim_time"]
      logo_image_url = ""
      total_votes = row["total_votes"].to_f
      
      unless row["url"].empty?
        bp_response = Typhoeus::Request.get(
          row["url"]+'/bp.json',
          followlocation: true,
          timeout: 5
        )
        
        if response.code == 200
          begin
            bp_json = JSON.parse bp_response.body
            if bp_json.has_key?("org") 
              if bp_json["org"].has_key?("location") and
                  bp_json["org"]["location"].has_key?("country")
                country = bp_json["org"]["location"]["country"]
              end
    
              if bp_json["org"].has_key?("branding")
                if bp_json["org"]["branding"].has_key?("logo_256") and
                    (not bp_json["org"]["branding"]["logo_256"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_256"]
                elsif bp_json["org"]["branding"].has_key?("logo_1024") and
                    (not bp_json["org"]["branding"]["logo_1024"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_1024"]
                elsif bp_json["org"]["branding"].has_key?("logo_svg") and
                    (not bp_json["org"]["branding"]["logo_svg"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_svg"]
                end
              end
            end
          rescue JSON::ParserError
            # Do nothing.
          end
        end
      end

      producer = Producer.find_or_initialize_by(owner: row["owner"]) do |r|
        r.country = country
        r.is_active = is_active
        r.last_claim_time = last_claim_time
        r.location = row["location"]
        r.logo_image_url = logo_image_url
        r.producer_key = row["producer_key"]
        r.rank = index + 1
        r.total_votes = total_votes
        r.unpaid_blocks = row["unpaid_blocks"]
        r.url = row["url"]
        r.prev_rank = index + 1
      end

      day_as_seconds = 86400
      prev_rank = producer.prev_rank
      unless producer.updated_at.nil?
        now_floor = floor_timestamp(day_as_seconds, Time.now)
        updated_at_floor = floor_timestamp(day_as_seconds, producer.updated_at)
        # Update prev_rank when first call of this function of day occurs.
        # For now, it would be UTC midnight.
        if now_floor != updated_at_floor
          prev_rank = producer.rank
        end
      end

      producer.update(
        country: country,
        is_active: is_active,
        last_claim_time: last_claim_time,
        location: row["location"],
        logo_image_url: logo_image_url,
        producer_key: row["producer_key"],
        rank: index + 1,
        prev_rank: prev_rank,
        total_votes: total_votes,
        unpaid_blocks: row["unpaid_blocks"],
        url: row["url"]
      )
    end
  end
end
