module ProjectsHelper
  def project_watch_button(project, params)
    return link_to(fa_icon('eye', text: t('buttons.watch')), watch_project_path(project, page: params[:page], tab: params[:tab]), method: :post, class: 'btn btn-sm btn-white', data: {tab: params[:tab]}) if project.unwatched?
    return link_to(fa_icon('eye-slash', text: t('buttons.unwatch')), watch_project_path(project, page: params[:page], tab: params[:tab]), method: :post, class: 'btn btn-sm btn-success', data: {tab: params[:tab]}) if project.watched?
  end
end
