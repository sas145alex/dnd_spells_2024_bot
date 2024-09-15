ActiveAdmin.register Spell do
  config.per_page = 30
  config.create_another = true

  permit_params :title, :description, :published

  index do
    selectable_column
    id_column
    column :title
    column :published_at
    column :created_at
    actions
  end

  filter :id
  filter :title
  filter :description
  filter :published_at
  filter :created_at, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :created_by, as: :select, collection: AdminUser.all.pluck(:email, :id)

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
    f.inputs do
      f.input :title
      f.input :description,
        label: "Description (#{Spell::DESCRIPTION_FORMAT})",
        as: :text,
        input_html: {rows: 12, style: "height:auto"}
      f.input :published_at, as: :boolean, label: "Published"
      li "Published at #{f.object.published_at}" if f.object.published?
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions
  end

  batch_action :publish do |ids|
    batch_action_collection.find(ids).each do |spell|
      spell.publish!
    end
    redirect_to collection_path, notice: "The spells have been published."
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
      attrs.merge(created_by: current_admin_user) if false
      attrs
    end

    def update_params
      attrs = permitted_params[:spell].to_h
      attrs.merge(updated_by: current_admin_user) if false
      attrs
    end
  end
end
