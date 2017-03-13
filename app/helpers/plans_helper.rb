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

  def execution_button(plan_id, scenario_id, params)
    plan = Plan.find plan_id
    return if plan.finished?
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

  def execution_remark_button(plan, scenario)
    execution = Execution.find_by_plan_id_and_scenario_id(plan, scenario)
    return nil if execution.nil?

    return link_to(fa_icon('comment-o', text: t('buttons.remarks')), new_execution_remark_path(execution), remote: true, class: 'btn btn-white btn-xs')
  end

  def plan_completion(plan)
    render partial: 'plans/plan_completion', locals: { plan: plan }
  end
end
