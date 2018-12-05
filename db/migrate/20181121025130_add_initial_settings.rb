class AddInitialSettings < ActiveRecord::Migration[5.2]
  def change
    Setting.create({new_account_cpu: 0.1,
      new_account_net: 0.1,
      new_account_ram: 3072,
      minimum_required_cpu: 0.8,
      minimum_required_net: 0.2,
      history_api_limit: 100,
      eosys_proxy_account: 'bpgovernance'
    })
  end
end
