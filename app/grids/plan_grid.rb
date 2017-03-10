class PlanGrid
  include Datagrid

  scope do
    Plan.order('plans.id desc')
  end

  column("project-status", header: '') do |asset|
    format(asset.state) do |value|
      plan_state_label(asset)
    end
  end

  column("name project-title", header: '') do |asset|
    format(asset.title) do |value|
      [
        link_to(value, plan_path(asset)),
        content_tag(:small, plan_duration_text(asset))
      ].join('<br />').html_safe
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        finish_plan_button(asset, 'btn btn-white btn-sm'),
        link_to(fa_icon("pencil"), edit_plan_path(asset), class: 'btn btn-white btn-sm', data: { toggle: 'tooltip', title: t('buttons.edit') }),
        link_to(fa_icon('trash'), plan_path(asset), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-sm')
      ].join(' ').html_safe
    end
  end
end
