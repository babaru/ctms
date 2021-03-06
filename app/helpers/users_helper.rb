module UsersHelper
  def user_time_tracking_button(user, options = {})
    default_options = {
      style: 'btn btn-sm'
    }
    options = options.merge(default_options)

    if user.time_tracking?
      button_text = fa_icon('calendar-minus-o', text: t('buttons.remove_from_time_tracking'))
      button_style = "#{options[:style]} btn-danger"
    else
      button_text = fa_icon('calendar-plus-o', text: t('buttons.add_to_time_tracking'))
      button_style = "#{options[:style]} btn-white"
    end
    link_to(button_text, user_time_tracking_path(user, redirect_url: request.original_fullpath), method: :post, class: button_style)
  end

  def user_avatar(user, options = {})
    default_options = {
      h: '25px',
      w: '30px'
    }
    options = options.merge(default_options)
    user_avatar_url = user.image.nil? ? image_url('default_avatar.png') : user.image
    content_tag(:span, image_tag(user_avatar_url, class: 'img-circle', style: "width:#{options[:h]};height:#{options[:h]};"), style: "width:#{options[:w]};height:#{options[:h]};display:inline-block;")
  end

  def user_avatar_with_name(user, options = {})
    [
      user_avatar(user),
      content_tag(:span, user.name, style: 'display:inline-block;height:30px;line-height: 35px;')
    ].join(' ').html_safe
  end
end
