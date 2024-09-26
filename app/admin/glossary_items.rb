ActiveAdmin.register GlossaryItem do
  scope :published, ->(scope) { scope.published }
  scope :not_published, ->(scope) { scope.not_published }

  index do
    selectable_column
    id_column
    column :category
    column :title
    column :original_title
    column :description do |glossary_item|
      markdown_to_html(glossary_item.description.first(300))
    end
    column :published_at
    column :created_at
    column :updated_at
    actions defaults: false do |glossary_item|
      links = []
      links << link_to(
        "Show",
        admin_glossary_item_path(glossary_item),
        class: "btn btn-primary"
      )
      links << link_to(
        "Edit",
        edit_admin_glossary_item_path(glossary_item),
        class: "btn btn-primary"
      )
      links << link_to(
        "Delete",
        admin_glossary_item_path(glossary_item),
        method: :delete,
        data: {confirm: "Are you sure?"},
        class: "btn btn-danger"
      )
      links.join(" ").html_safe
    end
  end

  filter :id
  filter :category, as: :select, collection: -> { GlossaryCategory.ordered }
  filter :title
  filter :original_title
  filter :description
  filter :published_at
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :updated_by, as: :select, collection: AdminUser.all.pluck(:email, :id)

  show do
    attributes_table_for(resource) do
      row :id
      row "parent category" do
        resource.category&.parent_category&.title
      end
      row :category
      row :title
      row :original_title
      row :description do
        markdown_to_html(resource.description)
      end
      row :published_at do
        if resource.published?
          span class: "badge badge-success" do
            resource.published_at
          end
        else
          span class: "badge badge-danger" do
            "Empty"
          end
        end
      end
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

    render "mentions"

    div do
      if resource.published?
        link_to "Unpublish", unpublish_admin_glossary_item_path(resource), class: "btn btn-primary"
      else
        link_to "Publish", publish_admin_glossary_item_path(resource), class: "btn btn-primary"
      end
    end
  end

  form do |f|
    categories = GlossaryCategory.ordered
    optgroups = categories
      .group_by { _1.top_level? ? "Top level" : _1.parent_category&.title }
      .transform_values { _1.pluck(:title, :id) }
    f.semantic_errors
    f.inputs do
      f.input :category,
        as: :select,
        collection: grouped_options_for_select(optgroups, f.object.category_id)
      f.input :title
      f.input :original_title
      f.input :description,
        label: "Description (#{GlossaryItem::DESCRIPTION_FORMAT})",
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

    unless f.object.new_record?
      f.actions do
        if f.object.published?
          li class: "action" do
            link_to "Unpublish", unpublish_admin_glossary_item_path(f.object)
          end
        else
          li class: "action" do
            link_to "Publish", publish_admin_glossary_item_path(f.object)
          end
        end
      end
    end
  end

  batch_action :publish do |ids|
    batch_action_collection.find(ids).each do |glossary_item|
      glossary_item.publish!
    end
    redirect_to collection_path, notice: "The items have been published."
  end

  batch_action :unpublish do |ids|
    batch_action_collection.find(ids).each do |glossary_item|
      glossary_item.unpublish!
    end
    redirect_to collection_path, notice: "The items have been unpublished."
  end

  member_action :publish, method: :get do
    resource.publish!
    redirect_to resource_path, notice: "Published!"
  end

  member_action :unpublish, method: :get do
    resource.unpublish!
    redirect_to resource_path, notice: "Unpublished!"
  end

  controller do
    def scoped_collection
      super.includes :category
    end

    def create
      @resource = GlossaryItem.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_glossary_item_path, notice: "GlossaryItem was successfully created. Create another one."
        else
          redirect_to admin_glossary_item_path(@resource), notice: "GlossaryItem was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_glossary_item_path(resource), notice: "GlossaryItem was successfully updated."
      else
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The glossary_item has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:glossary_item].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:glossary_item].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :original_title,
    :description,
    :category_id,
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
