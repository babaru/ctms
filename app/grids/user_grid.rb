class UserGrid
  include Datagrid

  scope do
    User.order('users.name asc')
  end

  column(:image, header: '') do |asset|
    format(asset.image) do |value|
      user_avatar(asset, {w: '30px', h: '30px'})
    end
  end

  column("name project-title", header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.name) do |value|
      [
        value,
        content_tag(:small, asset.email)
      ].join('<br />').html_safe
    end
  end

  column(:username, header: I18n.t('activerecord.attributes.user.username')) do |asset|
    format(asset.username) do |value|
      value
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        user_add_to_time_tracking_button(asset)
      ].join(' ').html_safe
    end
  end
end
