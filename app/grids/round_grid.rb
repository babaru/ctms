class RoundGrid
  include Datagrid

  scope do
    Round
  end

  # column("project-status", header: I18n.t('activerecord.attributes.round.state')) do |asset|
  #   format(asset.state) do |value|
  #     round_state_label(asset)
  #   end
  # end

  column("name issue-info", header: I18n.t('activerecord.attributes.round.title')) do |asset|
    format(asset.title) do |value|
      [
        link_to(value, plan_round_path(asset, plan_id: asset.plan_id)),
        content_tag(:small, round_duration_text(asset))
      ].join('<br />').html_safe
    end
  end

  column("project-completion", header: I18n.t('activerecord.attributes.round.completion')) do |asset|
    format(asset.title) do |value|
      round_progress(asset)
    end
  end

  column("project-actions", header: '') do |asset|
    format(asset.id) do |value|
      [
        # complete_round_button(asset),
        link_to(fa_icon("pencil"), edit_round_path(asset, redirect_url: request.original_fullpath), class: 'btn btn-white btn-sm', remote: true),
        link_to(fa_icon('trash'), round_path(asset, redirect_url: request.original_fullpath), method: :delete, data: { confirm: t('messages.delete_confirmation') }, class: 'btn btn-danger btn-sm')
      ].join(' ').html_safe
    end
  end
end
