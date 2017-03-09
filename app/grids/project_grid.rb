class ProjectGrid
  include Datagrid

  scope do
    Project.order('projects.name')
  end

  column("name project-title", header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.name) do |value|
      link_to value, project_path(asset)
    end
  end

  column(:issue_count, header: I18n.t('activerecord.attributes.project.issues')) do |asset|
    format(asset.issues.count) do |value|
      fa_icon('file', text: value)
    end
  end

  column(:scenario_count, header: I18n.t('activerecord.attributes.project.scenarios')) do |asset|
    format(asset.scenarios.count) do |value|
      fa_icon('video-camera', text: value)
    end
  end

  column("project-actions", header: '', html: {class: 'project-actions'}) do |asset|
    # format(asset.id) do |value|
    #   [
    #     link_to(fa_icon("pencil"), edit_project_path(asset), class: 'btn btn-white btn-sm', data: { toggle: 'tooltip', title: t('buttons.edit') }),
    #     link_to(fa_icon('trash'), project_path(asset), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-sm')
    #   ].join(' ').html_safe
    # end
    format(asset.id) do |value|
      [
        project_watch_button(asset, params)
      ].join(' ').html_safe
    end
  end
end
