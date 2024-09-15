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
  filter :created_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :description,
              label: "Description (#{Spell::DESCRIPTION_FORMAT})",
              as: :text,
              input_html: { rows: 12, style: 'height:auto' }
      f.input :published_at, as: :boolean, label: 'Published'
      li "Published at #{f.object.published_at}" if f.object.published?
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions
  end

  controller do
    def create
      @spell = Spell.new

      if @spell.update(update_params)
        if params[:create_another] == 'on'
          redirect_to new_admin_spell_path, notice: 'Spell was successfully created. Create another one.'
        else
          redirect_to edit_admin_spell_path(@spell), notice: 'Spell was successfully created.'
        end
      else
        flash.now[:alert] = 'Errors happened: ' + @spell.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if spell.update(update_params)
        redirect_to edit_admin_spell_path(spell), notice: 'Spell was successfully updated.'
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
