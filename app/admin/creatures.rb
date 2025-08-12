ActiveAdmin.register Creature do
  scope :published, ->(scope) { scope.published }
  scope :not_published, ->(scope) { scope.not_published }
  scope("My tasks") { |scope| scope.where(responsible: current_admin_user) }

  index do
    selectable_column
    id_column
    column :title do |resource|
      "#{resource.title} [#{resource.original_title}]"
    end
    column :creature_size do |resource|
      resource.human_enum_name(:creature_size)
    end
    column :creature_type do |resource|
      resource.human_enum_name(:creature_type)
    end
    column :challenge_rating
    column :edition_source
    column :description_size do |resource|
      ul do
        li "DB #{resource.description.size}"
        li "TG #{resource.decorate.description_for_telegram.size}"
        li "Lim #{ApplicationRecord::DESCRIPTION_LIMIT}"
      end
    end
    column :original_description_size do |resource|
      ul do
        li "DB #{resource.original_description.size}"
        li "TG #{resource.decorate.original_description_for_telegram.size}"
        li "Lim #{ApplicationRecord::DESCRIPTION_LIMIT}"
      end
    end
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
  filter :description
  filter :original_description
  filter :creature_size, as: :select, collection: Creature.human_enum_names(:creature_size)
  filter :creature_type, as: :select, collection: Creature.human_enum_names(:creature_type)
  filter :creature_subtype
  filter :challenge_rating
  filter :armor_class
  filter :hit_points
  filter :edition_source, as: :select, collection: Creature.distinct.pluck(:edition_source)
  filter :import_source
  filter :published_at
  filter :responsible, as: :select, collection: -> { admins_for_select }
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :created_at
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :original_title
      row :edition_source
      row :import_source
      row :creature_size do
        resource.human_enum_name(:creature_size)
      end
      row :creature_type do
        resource.human_enum_name(:creature_type)
      end
      row :creature_subtype
      row :challenge_rating
      row :armor_class
      row :hit_points
      row :hit_points_formula
      row :description do
        markdown_to_html(resource.description)
      end
      row :original_description do
        markdown_to_html(resource.original_description)
      end
      row :length do
        render partial: "description_length_badge", locals: {resource: resource, method: :description}
      end
      row :original_length do
        render partial: "description_length_badge", locals: {resource: resource, method: :original_description}
      end
      row :published_at do
        render partial: "published_badge", locals: {resource: resource}
      end
      row :responsible
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

    render "mentions"

    div do
      if resource.published?
        link_to "Unpublish", unpublish_admin_creature_path(resource), class: "btn btn-primary"
      else
        link_to "Publish", publish_admin_creature_path(resource), class: "btn btn-primary"
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :original_title
      f.input :edition_source
      f.input :import_source
      f.input :creature_size, as: :select, collection: Creature.human_enum_names(:creature_size)
      f.input :creature_type, as: :select, collection: Creature.human_enum_names(:creature_type)
      f.input :creature_subtype
      f.input :challenge_rating, as: :number, input_html: {step: 1.0, min: 0.0}
      f.input :armor_class
      f.input :hit_points
      f.input :hit_points_formula
      f.input :description,
        label: "Description (#{Creature::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}
      f.input :original_description,
        label: "Description (#{Creature::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}

      li "Published at #{f.object.published_at}" if f.object.published?
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
            link_to "Unpublish", unpublish_admin_creature_path(f.object)
          end
        else
          li class: "action" do
            link_to "Publish", publish_admin_creature_path(f.object)
          end
        end
      end
    end
  end

  batch_action :publish do |ids|
    batch_action_collection.find(ids).each do |creature|
      creature.publish!
    end
    redirect_to collection_path, notice: "The creatures have been published."
  end

  batch_action :unpublish do |ids|
    batch_action_collection.find(ids).each do |creature|
      creature.unpublish!
    end
    redirect_to collection_path, notice: "The creatures have been unpublished."
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
      @resource = Creature.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_creature_path, notice: "Creature was successfully created. Create another one."
        else
          redirect_to admin_creature_path(@resource), notice: "Creature was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_creature_path(resource), notice: "Creature was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The creature has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:creature].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:creature].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :original_title,
    :description,
    :original_description,
    :edition_source,
    :import_source,
    :creature_type,
    :creature_subtype,
    :challenge_rating,
    :armor_class,
    :hit_points,
    :hit_points_formula,
    :creature_size,
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
