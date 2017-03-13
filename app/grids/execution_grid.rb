class ExecutionGrid
  include Datagrid

  scope do
    Scenario.order('scenarios.id desc')
  end

  column(:title, header: I18n.t('activerecord.attributes.general.title')) do |asset|
    format(asset.title) do |value|
      extra_params = {}
      extra_params[:scenario_id] = asset.id
      extra_params[:tab] = params[:tab] if params[:tab]
      extra_params[:page] = params[:page] if params[:page]
      extra_params[:issue_id] = params[:issue_id] if params[:issue_id]
      link_to(value, plan_path(params[:id], extra_params))
    end
  end

  # column("name project-title", header: I18n.t('activerecord.attributes.general.name')) do |asset|
  #   format(asset.title) do |value|
  #     [
  #       link_to(value, execution_path(asset)),
  #       [
  #         content_tag(:small, "##{asset.gitlab_id}"),
  #         asset.milestone ? content_tag(:small, link_to(fa_icon('bookmark', text: asset.milestone.title), milestone_path(asset.milestone))) : '',
  #         asset.labels.inject([]) { |list, item| list << content_tag(:span, item, class: 'badge badge-default') }.join(' ').html_safe
  #       ].join(' ').html_safe
  #     ].join('<br />').html_safe
  #   end
  # end
  #
  # column("state", header: I18n.t('activerecord.attributes.execution.state')) do |asset|
  #   format(asset.state) do |value|
  #     content_tag(:span, value, class: 'badge badge-info')
  #   end
  # end
  #
  # column("scenarios", header: I18n.t('activerecord.attributes.execution.scenarios')) do |asset|
  #   format(asset.scenarios.count) do |value|
  #     fa_icon('video-camera', text: value)
  #   end
  # end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        # link_to(fa_icon('comment-o', ))
        execution_button(params[:id], asset.id, params),
        execution_remark_button(params[:id], asset.id)
      ].join(' ').html_safe
    end
  end

  # column("project-actions", header: '') do |asset|
  #   format(asset.id) do |value|
  #     [
  #       link_to(fa_icon("pencil"), edit_execution_path(asset), class: 'btn btn-white btn-sm', data: { toggle: 'tooltip', title: t('buttons.edit') }),
  #       link_to(fa_icon('trash'), execution_path(asset), method: :delete, data: { confirm: t('messages.delete_confirmation'), toggle: 'tooltip', title: t('buttons.delete') }, class: 'btn btn-danger btn-sm')
  #     ].join(' ').html_safe
  #   end
  # end
end
