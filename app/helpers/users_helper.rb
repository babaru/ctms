module UsersHelper
  def user_add_to_time_tracking_button(user, options = {})
    default_options = {
      style: 'btn btn-white btn-sm'
    }
    options = options.merge(default_options)

    if user.time_tracking?
      button_text = fa_icon('calendar-minus-o', text: t('buttons.remove_from_time_tracking'))
    else
      button_text = fa_icon('calendar-plus-o', text: t('buttons.add_to_time_tracking'))
    end
    link_to(button_text, user_time_tracking_path(user, redirect_url: request.original_fullpath), method: :post, class: options[:style])
  end

  def user_avatar(user, options = {})
    user_avatar_url = user.image.nil? ? image_url('default_avatar.png') : user.image
    content_tag(:span, image_tag(user_avatar_url, class: 'img-circle', style: "width:#{options[:h]};height:#{options[:h]};"), style: "width:#{options[:w]};height:#{options[:h]};display:inline-block;")
  end
end
