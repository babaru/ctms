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
    when PlanState.enums.unfinished
      content_tag(:span, state_text, class: 'label label-primary')
    when PlanState.enums.finished
      content_tag(:span, state_text, class: 'label label-default')
    end
  end

  def finish_plan_button(plan, options = {})
    default_options = {
      styles: {
        unfinished_style: 'btn btn-sm btn-white',
        finished_style: 'btn btn-sm btn-white'
      }
    }
    options = default_options.merge(options)
    if plan.unfinished?
      link_to fa_icon('check', text: t('activerecord.text.finish', model: Plan.model_name.human)), finish_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:unfinished_style]
    else
      link_to fa_icon('car', text: t('activerecord.text.start', model: Plan.model_name.human)), finish_plan_path(plan, redirect_url: request.original_fullpath), method: :post, class: options[:styles][:finished_style]
    end
  end

  def plan_progress(plan)
    render partial: 'plans/plan_progress', locals: { plan: plan }
  end

  def issue_title_with_progress(plan, issue)
    [
      issue.list_title,
      issue_progress(plan, issue)
    ].join(' ').html_safe
  end

  def issue_progress(plan, issue)
    return nil if issue.scenarios.count == 0
    content_tag(:span, "(#{Execution.executed(plan, issue).count}/#{issue.scenarios.count}) #{Execution.executed(plan, issue).count * 100 / issue.scenarios.count}%", class: 'label label-default')
  end
end
