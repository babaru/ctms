class ScenarioGrid
  include Datagrid

  scope do
    Scenario.order('scenarios.id desc')
  end

  column(:name, header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.title) do |value|
      link_to value, scenario_path(asset)
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        link_to(fa_icon("pencil"), edit_scenario_path(asset), class: 'btn btn-white btn-xs', data: { toggle: 'tooltip', title: t('buttons.edit') }),
        link_to(fa_icon('trash'), scenario_path(asset), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-xs')
      ].join(' ').html_safe
    end
  end
end
