ActiveAdmin.register User do
  menu priority: 2
  permit_params :state, :confirm_token

  index do
    selectable_column
    id_column
    column :email
    state_column :state
    column :eos_account
    column :ip_address
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :email
      state_row :state
      row :confirm_token
      row :eos_account
      row :ip_address
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :email, input_html: { readonly: true }
      f.input :state
      f.input :confirm_token
    end
    f.actions
  end
end
