ActiveAdmin.register Order do
  menu priority: 4
  permit_params :state
  actions :all, except: [:new, :create, :destroy]

  index do
    selectable_column
    id_column
    column :order_no
    column :eos_account
    state_column :state
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :order_no
      row :eos_account
      state_row :state
      tag_row :pgcode
      row :product_name
      row :public_key
      row :return_code
      row :return_message
      row :created_at
      row :updated_at
    end

    panel '가상계좌 정보' do
      table_for order do
        column :account_name
        column :account_no
        column :bank_code
        column :bank_name
        column :expire_date
      end
    end

    panel '결제 내역' do
      paginated_collection(order.payment_results.page(params[:payment_results_page]).per(15), param_name: 'payment_results_page', download_links: false) do
        table_for collection do
          column I18n.t('activerecord.attributes.attribute_commons.id') do |payment_result|
            link_to payment_result.id, admin_payment_result_path(payment_result)
          end
          column :cid
          column :tid
          column :pay_info
          column :transaction_date
          column :code
          column :message
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :state
    end
    f.actions
  end
end
