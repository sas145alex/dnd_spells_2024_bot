ActiveAdmin.register WildMagic do
  config.sort_order = "roll_asc"

  index do
    selectable_column
    id_column
    column :roll do |resource|
      resource.decorate.title
    end
    column :description do |resource|
      markdown_to_html(resource.description, limit: 300)
    end
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
  filter :roll
  filter :description
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :roll do
        resource.decorate.title
      end
      row :description do
        markdown_to_html(resource.description)
      end
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

    render "mentions"
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      li f.object.decorate.title
      f.input :description,
        label: "Description (#{WildMagic::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    panel "Mentions" do
      render partial: "mentions_form", locals: {f: f}
    end

    f.actions do
      f.add_create_another_checkbox
      f.action :submit
      f.cancel_link
    end
  end

  controller do
    def create
      @resource = WildMagic.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_wild_magic_path, notice: "WildMagic was successfully created. Create another one."
        else
          redirect_to admin_wild_magic_path(@resource), notice: "WildMagic was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_wild_magic_path(resource), notice: "WildMagic was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The wild_magic has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:wild_magic].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:wild_magic].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :roll,
    :description,
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
