ActiveAdmin.register Creature do
  scope :published, ->(scope) { scope.published }
  scope :not_published, ->(scope) { scope.not_published }
  scope("My tasks") { |scope| scope.where(responsible: current_admin_user) }

  index class: "asdf" do
    selectable_column
    id_column
    column :title
    column :original_title
    column :published_at
    column :created_at
    actions defaults: false do |creature|
      links = []
      links << link_to(
        "Show",
        admin_creature_path(creature),
        class: "btn btn-primary"
      )
      links << link_to(
        "Edit",
        edit_admin_creature_path(creature),
        class: "btn btn-primary"
      )
      links << link_to(
        "Delete",
        admin_creature_path(creature),
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
  filter :responsible, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :published_at
  filter :created_at
  filter :created_by, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :updated_by, as: :select, collection: AdminUser.all.pluck(:email, :id)

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :original_title
      row :description do |creature|
        markdown(creature.description)
      end
      row :length do |creature|
        span class: "badge #{creature.long_description? ? "badge-danger" : "badge-success"}" do
          "#{creature.description&.size} / #{Creature::DESCRIPTION_LIMIT}"
        end
      end
      row :published_at do |creature|
        if creature.published?
          span class: "badge badge-success" do
            creature.published_at
          end
        else
          span class: "badge badge-danger" do
            "Empty"
          end
        end
      end
      row :responsible
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

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
      f.input :description,
        label: "Description (#{Creature::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}

      li "Published at #{f.object.published_at}" if f.object.published?
      li "Created at #{f.object.created_at}" unless f.object.new_record?
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
      @creature = Creature.new

      if @creature.update(update_params)
        if params[:create_another] == "on"
          redirect_to new_admin_creature_path, notice: "Creature was successfully created. Create another one."
        else
          redirect_to admin_creature_path(@creature), notice: "Creature was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @creature.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if creature.update(update_params)
        redirect_to admin_creature_path(creature), notice: "Creature was successfully updated."
      else
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def creature
      @creature = Creature.find(params[:id])
    end

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
    :description
end
