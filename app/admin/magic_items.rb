ActiveAdmin.register MagicItem do
  scope :published, ->(scope) { scope.published }
  scope :not_published, ->(scope) { scope.not_published }

  index do
    selectable_column
    id_column
    column :category do |resource|
      resource.human_enum_name(:category)
    end
    column :rarity do |resource|
      resource.human_enum_name(:rarity)
    end
    column :attunement do |resource|
      resource.human_enum_name(:attunement)
    end
    column :title
    column :original_title
    column :description do |resource|
      markdown_to_html(resource.description.first(300))
    end
    column :price
    column :published_at
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
  filter :original_title
  filter :category, as: :select, collection: MagicItem.human_enum_names(:category)
  filter :rarity, as: :select, collection: MagicItem.human_enum_names(:rarity)
  filter :attunement, as: :select, collection: MagicItem.human_enum_names(:attunement)
  filter :charges
  filter :cursed
  filter :description
  filter :price
  filter :published_at
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :original_title
      row :category do
        "#{resource.category} - #{resource.human_enum_name(:category)}"
      end
      row :rarity do
        "#{resource.rarity} - #{resource.human_enum_name(:rarity)}"
      end
      row :attunement do
        "#{resource.attunement} - #{resource.human_enum_name(:attunement)}"
      end
      row :charges
      row :cursed
      row :price
      row :description do
        markdown_to_html(resource.description)
      end
      row :length do
        render partial: "description_length_badge", locals: {resource: resource}
      end
      row :published_at do
        render partial: "published_badge", locals: {resource: resource}
      end
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

    render "mentions"

    div do
      if resource.published?
        link_to "Unpublish", unpublish_admin_magic_item_path(resource), class: "btn btn-primary"
      else
        link_to "Publish", publish_admin_magic_item_path(resource), class: "btn btn-primary"
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :original_title
      f.input :category, as: :select, collection: f.object.class.categories
      f.input :rarity, as: :select, collection: f.object.class.rarities
      f.input :attunement, as: :select, collection: f.object.class.attunements
      f.input :charges
      f.input :cursed
      f.input :price
      f.input :description,
        label: "Description (#{MagicItem::DESCRIPTION_FORMAT})",
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
            link_to "Unpublish", unpublish_admin_magic_item_path(f.object)
          end
        else
          li class: "action" do
            link_to "Publish", publish_admin_magic_item_path(f.object)
          end
        end
      end
    end
  end

  batch_action :publish do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.publish!
    end
    redirect_to collection_path, notice: "The items have been published."
  end

  batch_action :unpublish do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.unpublish!
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
    def create
      @resource = MagicItem.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_magic_item_path, notice: "Record was successfully created. Create another one."
        else
          redirect_to admin_magic_item_path(@resource), notice: "Record was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to resource_path, notice: "Record was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The record has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:magic_item].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:magic_item].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :original_title,
    :description,
    :category,
    :rarity,
    :attunement,
    :charges,
    :cursed,
    :price,
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
