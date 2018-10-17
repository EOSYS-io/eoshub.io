ActiveAdmin.register PaymentResult do
  menu priority: 5
  actions :all, except: [:new, :create, :destroy, :update]

  index do
    selectable_column
    id_column
    column :order
    column :cid
    column :tid
    column :pay_info
    column :transaction_date
    actions
  end

  show do
    attributes_table do
      row :order
      row :cid
      row :tid
      row :pay_info
      row :transaction_date
      row :code
      row :message
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
