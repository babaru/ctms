class ScenarioGrid
  include Datagrid

  scope do
    Scenario.order('scenarios.issue_id')
  end

  column(:issue, header: I18n.t('activerecord.attributes.scenario.issue')) do |asset|
    format(asset.issue) do |value|
      link_to value.list_title, project_issue_path(value, project_id: asset.project)
    end
  end

  column(:scenario_title, header: I18n.t('activerecord.attributes.general.title')) do |asset|
    format(asset.title) do |value|
      link_to value, scenario_path(asset)
    end
  end

  column(:execution_title, header: I18n.t('activerecord.attributes.general.title')) do |asset|
    format(asset.title) do |value|
      link_to(value,
        plan_path(params[:id], {
          project_id: params[:project_id],
          label_id: params[:label_id],
          no_label: params[:no_label],
          page: params[:page],
          issue_id: params[:issue_id],
          scenario_id: asset.id
        }), class: (@scenario && @scenario.id == asset.id) ? 'active' : '')
    end
  end

  column(:labels, header: I18n.t('activerecord.attributes.scenario.labels'), mandatory: true) do |asset|
    format(asset.labels) do |value|
      scenario_labels(asset)
    end
  end

  column("execution_buttons project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        execution_remark_button(params[:id], asset, { button_size: 'xs' }),
        execution_button(params[:id], asset, params, { button_size: 'xs'})
      ].join(' ').html_safe
    end
  end

  column("crud_buttons project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        link_to(fa_icon("pencil"), edit_scenario_path(asset, redirect_url: request.original_fullpath), class: 'btn btn-white btn-xs', remote: true, data: { toggle: 'tooltip', title: t('buttons.edit') }),
        link_to(fa_icon('trash'), scenario_path(asset, redirect_url: request.original_fullpath), remote: true, method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-xs')
      ].join(' ').html_safe
    end
  end
end
