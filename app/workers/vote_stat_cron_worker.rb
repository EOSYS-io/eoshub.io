class VoteStatCronWorker
  include Sidekiq::Worker

  def perform(*args)
    safe_terminate = true
    first_request = true
    further_request_needed = true
    # From experiments, eosio table request returns up to 2500 rows.
    body = {code: "eosio", scope: "eosio", table: "voters", json: true, limit: 2500}

    total_voted_eos = 0
    total_staked_eos = 0
    eosys_proxy_account = "bpgovernance"
    eosys_proxy_staked_eos = 0
    eosys_proxy_staked_account_count = 0

    while further_request_needed do
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

      if response.code != 200
        safe_terminate = false
        break
      end

      response_json = JSON.parse response.body
      rows = response_json["rows"]

      unless first_request
        rows = rows.drop(1)
      end

      # Very execptional case, eosio table returns just one row.
      if rows.empty?
        break
      end

      rows.each do |row|
        staked_amount = row["staked"].to_i
        total_staked_eos += staked_amount

        # Check valid votes.
        if row["is_proxy"] == 1 or not (row["proxy"].empty? and row["producers"].empty?)
          total_voted_eos += staked_amount
        end

        if row["proxy"] == eosys_proxy_account
          eosys_proxy_staked_eos += staked_amount
          eosys_proxy_staked_account_count += 1
        end
      end

      body[:lower_bound] = rows.last["owner"]
      first_request = false
      further_request_needed = response_json["more"]
    end

    # Do nothing on unsafe termination.
    unless safe_terminate
      return
    end

    VoteStat.create(
      total_voted_eos: total_voted_eos.to_f/10000,
      total_staked_eos: total_staked_eos.to_f/10000,
      eosys_proxy_staked_eos: eosys_proxy_staked_eos.to_f/10000,
      eosys_proxy_staked_account_count: eosys_proxy_staked_account_count
    )
  end
end
