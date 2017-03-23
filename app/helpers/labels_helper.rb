module LabelsHelper
  def delete_label_button(label)
    return nil if label.is_existing_on_gitlab?
    return link_to(fa_icon('trash'), label_path(label, redirect_url: request.original_fullpath), method: :delete, data: { confirm: t('messages.delete_confirmation') }, class: 'btn btn-danger btn-xs')
  end

  def edit_label_button(label)
    return nil if label.is_existing_on_gitlab?
    return link_to(fa_icon('pencil'), edit_label_path(label, redirect_url: request.original_fullpath), remote: true, class: 'btn btn-white btn-xs')
  end

  def mark_requirement_label_button(label)
    if label.is_requirement?
      link_to fa_icon('flag-o', text: t('activerecord.text.unmark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-xs btn-white'
    else
      link_to fa_icon('flag', text: t('activerecord.text.mark_requirement', model: Label.model_name.human)), mark_requirement_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-xs btn-white'
    end
  end

  def mark_defect_label_button(label)
    if label.is_defect?
      link_to fa_icon('flag-o', text: t('activerecord.text.reset_defect', model: Label.model_name.human)), reset_defect_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-xs btn-white'
    else
      link_to fa_icon('bug', text: t('activerecord.text.set_defect', model: Label.model_name.human)), set_defect_label_path(label, redirect_url: request.original_fullpath), method: :post, class: 'btn btn-xs btn-white'
    end
  end
end
