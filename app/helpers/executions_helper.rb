module ExecutionsHelper
  def execution_button(plan_id, scenario_id, params, options = {})
    default_options = {
      button_size: 'sm'
    }
    options = default_options.merge(options)

    plan = Plan.find plan_id
    return if plan.finished?
    execution = Scenario.find(scenario_id).execution(plan_id)
    current_result = execution.result if execution
    current_result ||= ExecutionResult.enums.undone
    button_style = "btn-#{options[:button_size]}"
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
      plan_id: plan_id, scenario_id: scenario_id}
  end

  def execution_remark_button(plan, scenario, options = {})
    default_options = {
      button_size: 'sm'
    }
    options = default_options.merge(options)
    
    execution = Execution.find_by_plan_id_and_scenario_id(plan, scenario)
    return nil if execution.nil?
    render partial: 'executions/remarks_button', locals: { execution: execution, options: options }
  end
end
