module Redirectable
  PARAMETER_KEYS = {
    rounds: {
      show: [
        :controller,
        :action,
        :id,
        :plan_id,
        :issue_id,
        :project_id,
        :scenario_id,
        :label_id,
        :no_label,
        :execution_result,
        :unexecuted
      ]
    }
  }.freeze

  def build_redirect_url(new_params = {})
    params_hash = {}
    PARAMETER_KEYS[params[:controller].to_sym][params[:action].to_sym].each do |key|
      if new_params.key?(key)
        params_hash[key] = new_params[key]
      else
        params_hash[key] = params[key]
      end
    end
    url_for(params_hash)
  end
end
