ActiveAdmin.register MessageDistribution do
  index do
    selectable_column
    id_column
    column :title
    column :status
    column :recipients_count
    column :delivered_count
    column :failed_count
    column :finished_at
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
  filter :content
  filter :status, as: :select, collection: -> { MessageDistribution.statuses.keys }
  filter :created_at
  filter :updated_at
  filter :created_by, as: :select, collection: -> { admins_for_select }
  filter :updated_by, as: :select, collection: -> { admins_for_select }

  show do
    attributes_table_for(resource) do
      row :id
      row :status
      row :title
      row :content do
        markdown_to_html(resource.content)
      end
      row :created_at
      row :updated_at
      row :created_by
      row :updated_by
    end

    panel "Рассылка" do
      attributes_table_for(resource) do
        row :recipients_count
        row :delivered_count
        row :failed_count
        row :started_at
        row :finished_at
        row("Сегмент") do
          parts = []
          parts << "пользователи" if resource.send_to_users?
          parts << "чаты" if resource.send_to_chats?
          segment = "Каналы: #{parts.join(", ").presence || "—"}"
          segment += "; только активные" if resource.only_active?
          segment += "; активны с #{resource.active_since.to_fs(:short)}" if resource.active_since
          segment += "; запросов ≥ #{resource.min_command_count}" if resource.min_command_count
          segment
        end
      end
    end

    if resource.failed_count.positive?
      panel "Ошибки доставки" do
        table_for resource.deliveries.failed.group(:error_reason).count.to_a do
          column("Причина") { |row| row.first }
          column("Количество") { |row| row.last }
        end
      end
    end

    div do
      links = []
      if resource.sendable?
        links << link_to("Prepare sending", prepare_sending_admin_message_distribution_path(resource), class: "btn btn-primary")
      end
      links << link_to("Доставки", admin_message_deliveries_path(q: {message_distribution_id_eq: resource.id}), class: "btn btn-default")
      links.join(" ").html_safe
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :content,
        label: "Description (#{MessageDistribution::DESCRIPTION_FORMAT})",
        as: :simplemde_editor,
        input_html: {rows: 12, style: "height:auto"}
      li "Created at #{f.object.created_at}" unless f.object.new_record?
    end

    f.actions do
      f.action :submit
      f.cancel_link
    end
  end

  member_action :prepare_sending do
    redirect_to resource_path(resource), alert: "Рассылка уже была отправлена" unless resource.sendable?
  end

  member_action :submit_sending, method: :post do
    form = params.require(:message_distribution_sending_form)
    cast = ActiveModel::Type::Boolean.new

    if cast.cast(form[:test_sending])
      chat_ids = Array(form[:test_telegram_user_ids]) + form[:test_telegram_chat_ids].to_s.split(/[\s,]+/)
      MessageDistribution::TestSend.call(distribution: resource, chat_ids: chat_ids)
      redirect_to resource_path(resource), notice: "Тестовая отправка выполнена"
    else
      resource.update!(
        send_to_users: cast.cast(form[:send_to_users]),
        send_to_chats: cast.cast(form[:send_to_chats]),
        only_active: cast.cast(form[:only_active]),
        active_since: form[:active_since].presence,
        min_command_count: form[:min_command_count].presence
      )

      operation = MessageDistribution::Enqueue.new(distribution: resource)

      if operation.call
        redirect_to resource_path(resource), notice: "Рассылка запущена"
      else
        redirect_to resource_path(resource), alert: "Errors happened: " + operation.errors.full_messages.to_sentence
      end
    end
  end

  controller do
    def create
      @resource = MessageDistribution.new

      if @resource.update(create_params)
        if params[:create_another] == "on"
          redirect_to new_admin_message_distribution_path, notice: "MessageDistribution was successfully created. Create another one."
        else
          redirect_to admin_message_distribution_path(@resource), notice: "MessageDistribution was successfully created."
        end
      else
        flash.now[:alert] = "Errors happened: " + @resource.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      if resource.update(update_params)
        redirect_to admin_message_distribution_path(resource), notice: "MessageDistribution was successfully updated."
      else
        flash.now[:alert] = "Errors happened: " + resource.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "The message_distribution has been deleted."
      else
        redirect_to collection_path, alert: "Errors happened: " + resource.errors.full_messages.to_sentence
      end
    end

    private

    def create_params
      attrs = permitted_params[:message_distribution].to_h
      attrs[:created_by] = current_admin_user
      attrs
    end

    def update_params
      attrs = permitted_params[:message_distribution].to_h
      attrs[:updated_by] = current_admin_user
      attrs
    end
  end

  permit_params :title,
    :content
end
