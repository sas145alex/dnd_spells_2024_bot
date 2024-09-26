ActiveAdmin.register GlossaryCategory do
  index do
    selectable_column
    id_column
    column :title
    column :parent_category
    column :created_at
    column :updated_at
    actions defaults: false do |glossary_category|
      links = []
      links << link_to(
        "Show",
        admin_glossary_category_path(glossary_category),
        class: "btn btn-primary"
      )
      links << link_to(
        "Edit",
        edit_admin_glossary_category_path(glossary_category),
        class: "btn btn-primary"
      )
      links << link_to(
        "Delete",
        admin_glossary_category_path(glossary_category),
        method: :delete,
        data: {confirm: "Are you sure?"},
        class: "btn btn-danger"
      )
      links.join(" ").html_safe
    end
  end

  filter :title
  filter :parent_category
  filter :created_at
  filter :updated_at

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :parent_category
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :parent_category,
        as: :select,
        collection: GlossaryCategory.where.not(id: f.object.id).top_level.ordered
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions do
      f.add_create_another_checkbox
      f.action :submit
      f.cancel_link
    end
  end

  controller do
    def scoped_collection
      super.includes :parent_category
    end

    def create
      @resource = GlossaryCategory.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_glossary_category_path, notice: "GlossaryCategory was successfully created. Create another one."
        else
          redirect_to admin_glossary_category_path(@resource), notice: "GlossaryCategory was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_glossary_category_path(resource), notice: "GlossaryCategory was successfully updated."
      else
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The glossary_category has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      permitted_params[:glossary_category].to_h
    end

    def update_params
      permitted_params[:glossary_category].to_h
    end
  end

  permit_params :title,
    :parent_category_id
end
