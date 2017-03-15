class ScenarioGrid
  include Datagrid

  scope do
    Scenario.order('scenarios.issue_id')
  end

  column(:title, header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.title) do |value|
      link_to value, scenario_path(asset)
    end
  end

  column(:issue, header: I18n.t('activerecord.attributes.scenario.issue')) do |asset|
    format(asset.issue) do |value|
      link_to value.list_title, project_issue_path(value, project_id: asset.project)
    end
  end

  column(:labels, header: I18n.t('activerecord.attributes.scenario.labels')) do |asset|
    format(asset.labels) do |value|
      scenario_labels(asset)
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        link_to(fa_icon('tags'), scenario_labels_path(asset, redirect_url: request.original_fullpath), class: 'btn btn-white btn-xs', remote: true),
        link_to(fa_icon("pencil"), edit_scenario_path(asset), class: 'btn btn-white btn-xs', remote: true, data: { toggle: 'tooltip', title: t('buttons.edit') }),
        link_to(fa_icon('trash'), scenario_path(asset), remote: true, method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-xs')
      ].join(' ').html_safe
    end
  end
end
