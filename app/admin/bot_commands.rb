ActiveAdmin.register BotCommand do
  menu false

  index do
    selectable_column
    id_column
    column :title
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
  filter :description

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :description do |bot_command|
        markdown_to_html(bot_command.description)
      end
      row :length do |bot_command|
        span class: "badge #{bot_command.long_description? ? "badge-danger" : "badge-success"}" do
          "#{bot_command.description&.size} / #{resource.class::DESCRIPTION_LIMIT}"
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :description,
        label: "Description (#{f.object.class::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}

      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions do
      f.add_create_another_checkbox
      f.action :submit
      f.cancel_link
    end
  end

  controller do
    def create
      @bot_command = BotCommand.new

      if @bot_command.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_bot_command_path, notice: "Bot command was successfully created. Create another one."
        else
          redirect_to admin_bot_command_path(@bot_command), notice: "Bot command was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @bot_command.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_bot_command_path(resource), notice: "Bot command was successfully updated."
      else
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
      permitted_params[:bot_command].to_h
    end

    def update_params
      permitted_params[:bot_command].to_h
    end
  end

  permit_params :title, :description
end
