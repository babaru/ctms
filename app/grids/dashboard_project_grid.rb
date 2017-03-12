class DashboardProjectGrid
  include Datagrid

  scope do
    Project.order('projects.name')
  end

  column("title project-title", header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.title) do |value|
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

end
