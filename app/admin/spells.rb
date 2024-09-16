ActiveAdmin.register Spell do
  config.per_page = 30
  config.create_another = true

  scope :not_published, -> (scope) { scope.not_published }
  scope("My tasks") { |scope| scope.where(responsible: current_admin_user) }

  index do
    selectable_column
    id_column
    column :title
    column :published_at
    column :created_at
    actions defaults: false do |spell|
      links = []
      links << link_to("Show", action: :show, id: spell.id)
      links << link_to("Edit", action: :edit, id: spell.id)
      links << link_to(
        "Delete",
        admin_spell_path(spell),
        method: :delete,
        data: {confirm: 'Are you sure?'},
      )
      links.join(' ').html_safe
    end
  end

  filter :id
  filter :title
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
      row :description do |spell|
        markdown(spell.description)
      end
      row :published_at
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
      f.input :description,
        label: "Description (#{Spell::DESCRIPTION_FORMAT})",
        as: :text,
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
          li class: 'action' do
            link_to "Unpublish", unpublish_admin_spell_path(f.object)
          end
        else
          li class: 'action' do
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

  member_action :publish, method: :put do
    resource.publish!
    redirect_to resource_path, notice: "Published!"
  end

  member_action :unpublish, method: :put do
    resource.unpublish!
    redirect_to resource_path, notice: "Unpublished!"
  end

  controller do
    def create
      @spell = Spell.new

      if @spell.update(update_params)
        if params[:create_another] == "on"
          redirect_to new_admin_spell_path, notice: "Spell was successfully created. Create another one."
        else
          redirect_to edit_admin_spell_path(@spell), notice: "Spell was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @spell.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      binding.irb
      if spell.update(update_params)
        redirect_to edit_admin_spell_path(spell), notice: "Spell was successfully updated."
      else
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def spell
      @spell = Spell.find(params[:id])
    end

    def create_params
      attrs = permitted_params[:spell].to_h
      attrs.merge!(created_by: current_admin_user)
      attrs
    end

    def update_params
      attrs = permitted_params[:spell].to_h
      attrs.merge!(updated_by: current_admin_user)
      attrs
    end
  end

  permit_params :title, :description
end
