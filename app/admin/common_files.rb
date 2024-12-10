ActiveAdmin.register CommonFile do
  index do
    selectable_column
    id_column
    column :title
    column :created_at
    actions defaults: false do |resource|
      links = []
      links << link_to(
        "Show",
        resource_path(resource),
        class: "btn btn-primary"
      )
      links << link_to(
        "Edit",
        edit_resource_path(resource),
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
  filter :title

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :attachment do
        if resource.attachment.present?
          image_tag(resource.attachment_url)
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :attachment, as: :file, input_html: {accept: whitelisted_extensions_for(f.object, :attachment)}
      div do
        if f.object.attachment.present?
          image_tag(f.object.attachment_url)
        end
      end
    end

    f.actions do
      f.action :submit
      f.cancel_link
    end
  end

  permit_params :title, :attachment
end
