module LabelsHelper
  def delete_label_button(label)
    return nil if label.is_existing_on_gitlab?
    return link_to(fa_icon('trash'), label_path(label, redirect_url: request.original_fullpath), method: :delete, data: { confirm: t('messages.delete_confirmation') }, class: 'btn btn-danger btn-xs')
  end

  def edit_label_button(label)
    return nil if label.is_existing_on_gitlab?
    return link_to(fa_icon('pencil'), edit_label_path(label, redirect_url: request.original_fullpath), remote: true, class: 'btn btn-white btn-xs')
  end
end
