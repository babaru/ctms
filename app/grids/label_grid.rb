class LabelGrid
  include Datagrid

  scope do
    Label.order('labels.id desc')
  end

  column(:name, header: I18n.t('activerecord.attributes.general.name')) do |asset|
    format(asset.name) do |value|
      content_tag(:span, value, class: 'badge badge-info')
    end
  end

  column(:is_requirement, header: I18n.t('activerecord.attributes.label.is_requirement')) do |asset|
    format(asset.is_requirement?) do |value|
      fa_icon('star') if value
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        mark_requirement_label_button(asset)
      ].join(' ').html_safe
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        delete_label_button(asset)
      ].join(' ').html_safe
    end
  end
end
