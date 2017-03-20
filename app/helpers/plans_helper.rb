module PlansHelper
  def watch_plan_button(plan, options = {})
    default_options = {
      styles: {
        unwatched_style: 'btn btn-sm btn-white',
        watched_style: 'btn btn-sm btn-white'
      }
    }
    options = default_options.merge(options)
    return link_to(fa_icon('eye', text: t('buttons.watch')), watch_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:unwatched_style]) if plan.unwatched?(current_user)
    return link_to(fa_icon('eye-slash', text: t('buttons.unwatch')), watch_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:watched_style]) if plan.watched?(current_user)
  end

  def plan_duration_text(plan)
    fa_icon('calendar-check-o', text: "#{plan.started_at.strftime('%Y-%m-%d')} › #{plan.ended_at.strftime('%Y-%m-%d')}")
  end

  def plan_state_label(plan)
    state_text = Plan.state_names[plan.state]
    case plan.state
    when TestSuiteState.enums.incomplete
      content_tag(:span, state_text, class: 'label label-primary')
    when TestSuiteState.enums.complete
      content_tag(:span, state_text, class: 'label label-default')
    end
  end

  def complete_plan_button(plan, options = {})
    default_options = {
      styles: {
        incomplete_style: 'btn btn-sm btn-white',
        complete_style: 'btn btn-sm btn-white'
      }
    }
    options = default_options.merge(options)
    if plan.incomplete?
      link_to fa_icon('check', text: t('activerecord.text.complete', model: Plan.model_name.human)), complete_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:incomplete_style]
    else
      link_to fa_icon('car', text: t('activerecord.text.start', model: Plan.model_name.human)), complete_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:complete_style]
    end
  end
end
