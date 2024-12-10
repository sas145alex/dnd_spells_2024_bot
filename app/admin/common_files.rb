ActiveAdmin.register CommonFile do
  index do
    selectable_column
    id_column
    column :title
    column :attachment do |resource|
      if resource.attachment.present? && resource.attachment.image?
        url = cloudinary_url(resource.attachment.key, width: 200, height: 150, crop: "scale")
        image_tag(url)
      end
    end
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
      row :attachment_url do
        resource.attachment.url
      end
      row :attachment do
        if resource.attachment.present?
          image_tag(resource.attachment)
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
      f.input :attachment,
        as: :file,
        input_html: {accept: f.object.class::ATTACHMENT_CONTENT_TYPES.map { ".#{_1}" }.join(",")}
      div do
        span do
          f.object.attachment&.filename
        end
        div do
          if f.object.attachment.present? && f.object.attachment.image?
            url = cloudinary_url(f.object.attachment.key, width: 300, height: 200, crop: "scale")
            image_tag(url)
          end
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
