ActiveAdmin.register Spell do
  scope :published, ->(scope) { scope.published }
  scope :not_published, ->(scope) { scope.not_published }
  scope("My tasks") { |scope| scope.where(responsible: current_admin_user) }

  index do
    selectable_column
    id_column
    column :title
    column :original_title
    column :level
    column :published_at
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
  filter :original_title
  filter :level
  filter :school
  filter :ritual
  filter :concentration
  filter :casting_time,
    as: :select,
    collection: Spell.human_enum_names(:casting_time)
  filter :description
  filter :character_klasses_id_in,
    label: "Character Klass",
    as: :select,
    collection: CharacterKlass.all.order(parent_klass_id: :desc),
    multiple: true
  filter :requested_count
  filter :responsible, as: :select, collection: -> { admins_for_select }
  filter :published_at
  filter :created_at
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :level
      row :school do
        if resource.school.present?
          "#{resource.school} - #{resource.human_enum_name(:school)}"
        else
          "-"
        end
      end
      row :casting_time do
        resource.human_enum_name(:casting_time)
      end
      row :ritual
      row :concentration
      row :title
      row :original_title
      row :description do
        markdown_to_html(resource.description)
      end
      row :length do
        render partial: "description_length_badge", locals: {resource: resource, method: :description}
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

    panel "Character Klasses (#{resource.character_klasses.size})" do
      table_for resource.character_klasses do
        column :title do |klass|
          link_to klass.title, admin_character_klass_path(klass)
        end
        column :created_at
      end
    end

    render "mentions"

    div do
      if resource.published?
        link_to "Unpublish", unpublish_admin_spell_path(resource), class: "btn btn-primary"
      else
        link_to "Publish", publish_admin_spell_path(resource), class: "btn btn-primary"
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :level
      f.input :school, as: :select, collection: schools_for_select
      f.input :casting_time, as: :select, collection: Spell.human_enum_names(:casting_time)
      f.input :ritual
      f.input :concentration
      f.input :title
      f.input :original_title
      f.input :description,
        label: "Description (#{Spell::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}

      li "Published at #{f.object.published_at}" if f.object.published?
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    panel "Character Klasses" do
      f.has_many :spells_character_klasses, heading: false, allow_destroy: true do |nf|
        nf.input :character_klass,
          as: :select,
          collection: CharacterKlass.all,
          selected: nf.object.character_klass_id
      end
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
            link_to "Unpublish", unpublish_admin_spell_path(f.object)
          end
        else
          li class: "action" do
            link_to "Publish", publish_admin_spell_path(f.object)
          end
        end
      end
    end
  end

  batch_action :publish do |ids|
    batch_action_collection.find(ids).each do |spell|
      spell.publish!
    end
    redirect_to collection_path, notice: "The spells have been published."
  end

  batch_action :unpublish do |ids|
    batch_action_collection.find(ids).each do |spell|
      spell.unpublish!
    end
    redirect_to collection_path, notice: "The spells have been unpublished."
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
      @resource = Spell.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_spell_path, notice: "Spell was successfully created. Create another one."
        else
          redirect_to admin_spell_path(@resource), notice: "Spell was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_spell_path(resource), notice: "Spell was successfully updated."
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
      attrs = permitted_params[:spell].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:spell].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :level,
    :school,
    :ritual,
    :concentration,
    :casting_time,
    :original_title,
    :description,
    spells_character_klasses_attributes: [:id, :character_klass_id, :_destroy],
    mentions_attributes: [:id, :another_mentionable_type, :another_mentionable_id, :_destroy]
end
