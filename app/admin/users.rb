ActiveAdmin.register User do
  menu priority: 2
  permit_params :state, :confirm_token

  show do
    attributes_table do
      row :email
      state_row :state
      row :confirm_token
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
