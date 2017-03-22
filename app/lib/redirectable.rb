module Redirectable
  def build_redirect_url(new_params = {})
    params_hash = {}
    params_keys = Object.const_get("#{params[:controller].capitalize}Controller")::PARAMETER_KEYS[params[:action].to_sym]
    [[:controller, :action], params_keys].flatten.each do |key|
      if new_params.key?(key)
        params_hash[key] = new_params[key]
      else
        params_hash[key] = params[key]
      end
    end
    url_for(params_hash)
  end

  alias_method :build_url, :build_redirect_url

  def redirect_url
    @redirect_url
  end
end
