module PlansHelper
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
end
