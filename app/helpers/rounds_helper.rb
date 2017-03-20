module RoundsHelper
  def round_duration_text(round)
    fa_icon('calendar-check-o', text: "#{round.started_at.strftime('%Y-%m-%d')} › #{round.ended_at.strftime('%Y-%m-%d')}")
  end

  def round_state_label(round)
    state_text = Round.state_names[round.state]
    case round.state
    when TestSuiteState.enums.incomplete
      content_tag(:span, state_text, class: 'label label-primary')
    when TestSuiteState.enums.complete
      content_tag(:span, state_text, class: 'label label-default')
    end
  end

  def complete_round_button(round, options = {})
    default_options = {
      styles: {
        incomplete_style: 'btn btn-sm btn-white',
        complete_style: 'btn btn-sm btn-white'
      }
    }
    options = default_options.merge(options)
    if round.incomplete?
      link_to fa_icon('check', text: t('activerecord.text.complete', model: Round.model_name.human)), complete_round_path(round, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:incomplete_style]
    else
      link_to fa_icon('car', text: t('activerecord.text.start', model: Round.model_name.human)), complete_round_path(round, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:complete_style]
    end
  end

  def round_progress(round)
    render partial: 'rounds/progress', locals: { round: round }
  end
end
