ActiveAdmin.register Setting do
  menu priority: 8
  permit_params :eosys_proxy_account, 
    :history_api_limit,
    :minimum_required_cpu,
    :minimum_required_net,
    :new_account_cpu,
    :new_account_net,
    :new_account_ram
  actions :index, :show, :update, :edit

  index do
    column :new_account_cpu
    column :new_account_net
    column :new_account_ram
    column :minimum_required_cpu
    column :minimum_required_net
    column :eosys_proxy_account
    column :history_api_limit
    actions
  end

  form do |f|
    f.inputs '계정 생성' do
      f.input :new_account_cpu
      f.input :new_account_net
      f.input :new_account_ram
    end
    f.inputs '최소 스테이킹 리소스' do
      f.input :minimum_required_cpu
      f.input :minimum_required_net
    end
    f.inputs '검색' do
      f.input :history_api_limit
    end
    f.inputs '투표' do
      f.input :eosys_proxy_account
    end
    f.actions
  end
end
