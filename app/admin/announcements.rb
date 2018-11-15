ActiveAdmin.register Announcement do
  menu priority: 7
  permit_params :title_ko, :title_en, :title_cn, :body_ko, :body_en, :body_cn, :published_at, :ended_at
  
  index do
    selectable_column
    id_column
    column :title_ko
    toggle_bool_column :active
    column :published_at
    column :ended_at
    actions
  end

  show do
    attributes_table do
      row :title_ko
      row :title_en
      row :title_cn
      row :body_ko
      row :body_en
      row :body_cn
      bool_row :active
      row :published_at
      row :ended_at
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
  
  form do |f|
    f.inputs '제목' do
      f.input :title_ko
      f.input :title_en
      f.input :title_cn
      f.input :active
    end
    f.inputs '내용' do
      f.input :body_ko
      f.input :body_en
      f.input :body_cn
    end
    f.inputs '기간 설정' do
      f.input :published_at
      f.input :ended_at
    end
    f.actions
  end
end
