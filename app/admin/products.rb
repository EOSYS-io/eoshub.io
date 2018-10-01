ActiveAdmin.register Product do
  permit_params :active, :name, :price

  index do
    selectable_column
    id_column
    toggle_bool_column :active
    column :name
    number_column :price, as: :currency, unit: "원", separator: ","
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      bool_row :active
      row :name
      number_row :price, as: :currency, unit: "원", separator: ","
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :active
      f.input :name
      f.input :price
    end
    f.actions
  end
end
