ActiveAdmin.register CharacterKlass do
  index do
    selectable_column
    id_column
    column :title
    column :original_title
    column :parent_klass
    column :description do |resource|
      markdown_to_html(resource.description.first(300))
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
  filter :title
  filter :parent_klass, collection: -> { CharacterKlass.base_klasses }
  filter :original_title
  filter :description
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :updated_by, as: :select, collection: AdminUser.all.pluck(:email, :id)

  show do
    attributes_table_for(resource) do
      row :id
      row :parent_klass, collection: CharacterKlass.base_klasses
      row :title
      row :original_title
      row :description do
        markdown_to_html(resource.description)
      end
      row :length do
        render partial: "description_length_badge", locals: {resource: resource}
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
      f.input :parent_klass, collection: CharacterKlass.base_klasses
      f.input :title
      f.input :original_title
      f.input :description,
        label: "Description (#{CharacterKlass::DESCRIPTION_FORMAT})",
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
      @resource = CharacterKlass.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_resource_path(@resource), notice: "CharacterKlass was successfully created. Create another one."
        else
          redirect_to resource_path(@resource), notice: "CharacterKlass was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to resource_path(resource), notice: "CharacterKlass was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The character_klass has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:character_klass].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:character_klass].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :original_title,
    :description,
    :parent_klass_id,
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
