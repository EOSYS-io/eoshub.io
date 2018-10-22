ActiveAdmin.register Product do
  menu priority: 3
  permit_params :active, :name, :price, :event_activation, :cpu, :net, :ram

  index do
    selectable_column
    id_column
    toggle_bool_column :active
    toggle_bool_column :event_activation
    column :name
    number_column :price, as: :currency, unit: "원"
    number_column :cpu, as: :currency, unit: "EOS", precision: 4
    number_column :net, as: :currency, unit: "EOS", precision: 4
    number_column :ram, as: :human_size, locale: :en
    actions
  end

  show do
    attributes_table do
      bool_row :active
      bool_row :event_activation
      row :name
      number_row :price, as: :currency, unit: "원"
      number_row :cpu, as: :currency, unit: "EOS", precision: 4
      number_row :net, as: :currency, unit: "EOS", precision: 4
      number_row :ram, as: :human_size, locale: :en
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :active
      f.input :event_activation
      f.input :name
      f.input :price
      f.input :cpu, label: 'CPU(EOS)'
      f.input :net, label: 'NET(EOS)'
      f.input :ram, label: 'RAM(bytes)'
    end
    f.actions
  end
end
