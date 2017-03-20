class PlanGrid
  include Datagrid

  scope do
    Plan.order('plans.id desc')
  end

  # column("project-status", header: I18n.t('activerecord.attributes.plan.state')) do |asset|
  #   format(asset.state) do |value|
  #     plan_state_label(asset)
  #   end
  # end

  column("name issue-info", header: I18n.t('activerecord.attributes.plan.title')) do |asset|
    format(asset.title) do |value|
      [
        link_to(value, plan_path(asset)),
        content_tag(:small, plan_duration_text(asset))
      ].join('<br />').html_safe
    end
  end

  column("rounds", header: I18n.t('activerecord.attributes.plan.rounds')) do |asset|
    format(asset.rounds.count) do |value|
      value
    end
  end

  # column("project-actions", header: '') do |asset|
  #   format(asset.id) do |value|
  #     [
  #       plan_current_active_round_button(asset)
  #     ].join(' ').html_safe
  #   end
  # end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        # complete_plan_button(asset),
      ].join(' ').html_safe
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        watch_plan_button(asset),
        link_to(fa_icon("pencil"), edit_plan_path(asset, redirect_url: request.original_fullpath), class: 'btn btn-white btn-sm', data: { toggle: 'tooltip', title: t('buttons.edit') }),
        link_to(fa_icon('trash'), plan_path(asset, redirect_url: request.original_fullpath), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-sm')
      ].join(' ').html_safe
    end
  end
end
