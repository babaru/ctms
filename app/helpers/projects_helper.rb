module ProjectsHelper
  def project_watch_button(project, params)
    return link_to(fa_icon('eye', text: t('buttons.watch')), watch_project_path(project, page: params[:page], tab: params[:tab]), method: :post, class: 'btn btn-sm btn-white', data: {tab: params[:tab]}) if project.unwatched?
    return link_to(fa_icon('eye-slash', text: t('buttons.unwatch')), watch_project_path(project, page: params[:page], tab: params[:tab]), method: :post, class: 'btn btn-sm btn-success', data: {tab: params[:tab]}) if project.watched?
  end

  def mark_requirement_label_button(label)
    if label.is_requirement?
      link_to fa_icon('flag-o', text: t('activerecord.text.unmark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-sm btn-white'
    else
      link_to fa_icon('flag', text: t('activerecord.text.mark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-sm btn-warning'
    end
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
end
