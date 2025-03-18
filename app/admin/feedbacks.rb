ActiveAdmin.register Feedback do
  index do
    selectable_column
    id_column
    column :external_user_id
    column :message
    column :created_at
    actions defaults: false do |resource|
      links = []
      links << link_to(
        "Show",
        resource_path(resource),
        class: "btn btn-primary"
      )
      links << link_to(
        "Delete",
        resource_path(resource),
        method: :delete,
        data: {confirm: "Are you sure?"},
        class: "btn btn-danger"
      )
      links.join(" ").html_safe
    end
  end

  filter :id
  filter :external_user_id
  filter :message
  filter :created_at
  filter :updated_at

  show do
    attributes_table_for(resource) do
      row :id
      row :external_user_id
      row :message
      row :payload
      row :created_at
      row :updated_at
    end
  end
end
