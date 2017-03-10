class ExecutionResult < ::Settingslogic
  source "#{Rails.root}/config/tms/execution_results.yml"
  namespace Rails.env
end
