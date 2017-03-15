class IssueGrid
  include Datagrid

  scope do
    Issue.order('issues.id desc')
  end

  column("state", header: I18n.t('activerecord.attributes.issue.state')) do |asset|
    format(asset.state) do |value|
      issue_state_label(asset)
    end
  end

  column("issue-info", header: I18n.t('activerecord.attributes.issue.title')) do |asset|
    format(asset.title) do |value|
      [
        link_to("ISSUE-#{asset.gitlab_id} #{value}", project_issue_path(asset, project_id: asset.project_id)),
        content_tag(:small, "#{asset.description.truncate(150)}")
      ].join('<br />').html_safe
    end
  end

  column('assignee', header: I18n.t('activerecord.attributes.issue.assignee')) do |asset|
    format(asset.assignee) do |value|
      user_avatar_with_name(asset.assignee) if asset.assignee
    end
  end

  column('author', header: I18n.t('activerecord.attributes.issue.user')) do |asset|
    format(asset.user) do |value|
      user_avatar_with_name(asset.user) if asset.user
    end
  end

  column("scenarios", header: I18n.t('activerecord.attributes.issue.scenarios')) do |asset|
    format(asset.scenarios.count) do |value|
      fa_icon('video-camera', text: value)
    end
  end

  column('milestone', header: '') do |asset|
    format(asset.milestone) do |value|
      asset.milestone ? content_tag(:small, link_to(fa_icon('bookmark', text: asset.milestone.title), milestone_path(asset.milestone))) : ''
    end
  end

  column('labels', header: '') do |asset|
    format(asset.id) do |value|
      asset.labels.inject([]) { |list, item| list << content_tag(:span, item.name, class: 'badge badge-default') }.join(' ').html_safe
    end
  end

  # column("project-actions", header: '') do |asset|
  #   format(asset.id) do |value|
  #     [
  #       link_to(fa_icon("pencil"), edit_issue_path(asset), class: 'btn btn-white btn-sm', data: { toggle: 'tooltip', title: t('buttons.edit') }),
  #       link_to(fa_icon('trash'), issue_path(asset), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-sm')
  #     ].join(' ').html_safe
  #   end
  # end
end
