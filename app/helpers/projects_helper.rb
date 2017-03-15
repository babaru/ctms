module ProjectsHelper
  def watch_project_button(project, options = {})
    default_options = {
      styles: {
        unwatched_style: 'btn btn-sm btn-white',
        watched_style: 'btn btn-sm btn-white'
      }
    }
    options = default_options.merge(options)
    return link_to(fa_icon('eye', text: t('buttons.watch')), watch_project_path(project, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:unwatched_style]) if project.unwatched?(current_user)
    return link_to(fa_icon('eye-slash', text: t('buttons.unwatch')), watch_project_path(project, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:watched_style]) if project.watched?(current_user)
  end

  def project_add_to_time_tracking_button(project, options = {})
    default_options = {
      style: 'btn btn-white btn-sm'
    }
    options = options.merge(default_options)

    if project.time_tracking?
      button_text = fa_icon('calendar-minus-o', text: t('buttons.remove_from_time_tracking'))
    else
      button_text = fa_icon('calendar-plus-o', text: t('buttons.add_to_time_tracking'))
    end
    link_to(button_text, project_time_tracking_path(project, redirect_url: request.original_fullpath), method: :post, class: options[:style])
  end

  def mark_requirement_label_button(label)
    if label.is_requirement?
      link_to fa_icon('flag-o', text: t('activerecord.text.unmark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-sm btn-white'
    else
      link_to fa_icon('flag', text: t('activerecord.text.mark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-sm btn-warning'
    end
  end

  def refresh_project_gitlab_data_button(project, options = {})
    default_options = {
      style: ''
    }
    options = default_options.merge(options)
    link_to fa_icon('refresh', text: t('activerecord.text.sync_from_gitlab', model: Issue.model_name.human)), sync_issues_from_gitlab_path(project_id: project, redirect_url: request.original_fullpath), method: :post, class: options[:style]
  end

  def refresh_project_gitlab_time_sheet_data_button(project, options = {})
    default_options = {
      style: ''
    }
    options = default_options.merge(options)
    link_to fa_icon('refresh', text: t('activerecord.text.sync_from_gitlab', model: TimeSheet.model_name.human)), sync_project_time_sheets_from_gitlab_path(project, redirect_url: request.original_fullpath), method: :post, class: options[:style]
  end

  def label_button_group(project)
    extra_params = {}
    extra_params[:tab] = params[:tab] if params[:tab]
    extra_params[:page] = params[:page] if params[:page]
    label_id = params[:label_id]
    group = []
    group << link_to(t('activerecord.text.all', model: Label.model_name.human), project_path(project, extra_params), class: "btn btn-sm btn-white #{label_id.nil? ? 'active' : ''}")
    project.labels.requirements.each do |label|
      group << link_to(label.name, project_path(project, extra_params.merge(label_id: label.id)), class: "btn-sm btn btn-white #{label_id == label.id.to_s ? 'active' : ''}")
    end
    group.join('').html_safe
  end

  def issue_state_label(issue)
    if issue.opened?
      content_tag(:span, issue.state, class: 'label label-info')
    else
      content_tag(:span, issue.state, class: 'label label-default')
    end
  end
end
