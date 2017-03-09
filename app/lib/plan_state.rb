
class PlanState < ::Settingslogic
  source "#{Rails.root}/config/tms/plan_states.yml"
  namespace Rails.env
end
