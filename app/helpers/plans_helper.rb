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

  def execution_button(plan_id, scenario_id, params)
    execution = Scenario.find(scenario_id).execution(plan_id)
    current_result = execution.result if execution
    current_result ||= ExecutionResult.enums.undone
    button_style = 'btn-xs'
    case current_result
    when ExecutionResult.enums.undone
      button_style = "#{button_style} btn-white"
    when ExecutionResult.enums.na
      button_style = "#{button_style} btn-warning"
    when ExecutionResult.enums.passed
      button_style = "#{button_style} btn-primary"
    when ExecutionResult.enums.failed
      button_style = "#{button_style} btn-danger"
    end
    extra_params = {}
    extra_params[:scenario_id] = scenario_id
    extra_params[:plan_id] = plan_id
    extra_params[:tab] = params[:tab] if params[:tab]
    extra_params[:page] = params[:page] if params[:page]
    extra_params[:issue_id] = params[:issue_id] if params[:issue_id]
    render partial: 'plans/execution_button', locals: {
      current_result: current_result, button_style: button_style,
      params: extra_params}
  end
end
