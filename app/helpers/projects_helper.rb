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
end
