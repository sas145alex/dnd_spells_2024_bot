ActiveAdmin.register MessageDistribution do
  index do
    selectable_column
    id_column
    column :title
    column :content do |resource|
      markdown_to_html(resource.content, limit: 300)
    end
    column :last_sent_at
    column :created_at
    column :updated_at
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
  filter :content
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :last_sent_at
      row :title
      row :content do
        markdown_to_html(resource.content)
      end
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :content,
        label: "Description (#{MessageDistribution::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions do
      f.action :submit
      f.cancel_link
    end
  end

  controller do
    def create
      @resource = MessageDistribution.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_message_distribution_path, notice: "MessageDistribution was successfully created. Create another one."
        else
          redirect_to admin_message_distribution_path(@resource), notice: "MessageDistribution was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_message_distribution_path(resource), notice: "MessageDistribution was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The message_distribution has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:message_distribution].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:message_distribution].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :content
end
