class IssueGrid
  include Datagrid

  scope do
    Issue.order(:state).reverse_order
  end

  column(:gitlab_id, header: I18n.t('activerecord.attributes.issue.gitlab_id'), mandatory: true) do |asset|
    format(asset.gitlab_id) do |value|
      "##{value}"
    end
  end

  column("state", header: I18n.t('activerecord.attributes.issue.state')) do |asset|
    format(asset.state) do |value|
      issue_state_label(asset)
    end
  end

  column("title issue-info", header: I18n.t('activerecord.attributes.issue.title')) do |asset|
    format(asset.title) do |value|
      [
        link_to(issue_title_with_labels(asset), build_url({issue_id: asset, tab: :scenarios})),
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

  column('milestone', header: I18n.t('activerecord.attributes.issue.milestone')) do |asset|
    format(asset.milestone) do |value|
      milestone_badge(value)
    end
  end

  column('round', header: I18n.t('activerecord.attributes.defect.round')) do |asset|
    format(asset.round) do |value|
      link_to value.title, plan_round_path(value, plan_id: value.plan_id) if value
    end
  end

  column('corresponding_issue', header: I18n.t('activerecord.attributes.defect.corresponding_issue')) do |asset|
    format(asset.corresponding_issue) do |value|
      link_to value.list_title, project_issue_path(value, project_id: value.project_id) if value
    end
  end

  column("defect project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        link_to(fa_icon("pencil", text: t('activerecord.text.edit_defect_corresponding_info')), edit_defect_corresponding_path(asset, redirect_url: request.original_fullpath), remote: true, class: 'btn btn-white btn-sm'),
      ].join(' ').html_safe
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
