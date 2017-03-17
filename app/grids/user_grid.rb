class UserGrid
  include Datagrid

  scope do
    User.order('users.name asc')
  end

  column("name project-title", header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.name) do |value|
      [
        user_avatar_with_name(asset),
        content_tag(:small, asset.email)
      ].join('<br />').html_safe
    end
  end

  column(:username, header: I18n.t('activerecord.attributes.user.username')) do |asset|
    format(asset.username) do |value|
      value
    end
  end

  column(:last_sign_in_at, header: I18n.t('activerecord.attributes.user.last_sign_in_at')) do |asset|
    format(asset.last_sign_in_at) do |value|
      value.strftime('%Y-%m-%d %H:%M:%S') if value
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        user_time_tracking_button(asset)
      ].join(' ').html_safe
    end
  end
end
