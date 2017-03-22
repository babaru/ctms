module ExecutionsHelper
  def execution_button(execution, options = {})
    default_options = {
      button_style: 'btn btn-sm'
    }
    options = default_options.merge(options)
    button_style = "btn-#{options[:button_size]}"
    case execution.result
    when ExecutionResult.enums.unexecuted
      options[:button_style] = "#{options[:button_style]} btn-white"
    when ExecutionResult.enums.na
      options[:button_style] = "#{options[:button_style]} btn-warning"
    when ExecutionResult.enums.passed
      options[:button_style] = "#{options[:button_style]} btn-primary"
    when ExecutionResult.enums.failed
      options[:button_style] = "#{options[:button_style]} btn-danger"
    end

    render partial: 'executions/execution_button', locals: { execution: execution, options: options }
  end

  def execution_remark_button(execution, options = {})
    default_options = {
      button_style: 'btn btn-sm btn-white',
      button_label: true,
      style: :dropdown
    }
    options = default_options.merge(options)
    render partial: 'executions/remarks_button', locals: { execution: execution, options: options }
  end

  def execution_post_defect_button(execution, options = {})
    default_options = {
      button_style: 'btn btn-sm btn-white',
      button_label: true
    }
    options = default_options.merge(options)

    link_to(fa_icon('bug', text: options[:button_label] ? t('buttons.post_defect') : ''), new_defect_path({
      project_id: execution.scenario.project,
      scenario_id: execution.scenario,
      round_id: execution.round,
      corresponding_issue_id: execution.issue,
      redirect_url: request.original_fullpath}),
        remote: true,
        class: options[:button_style])
  end
end
