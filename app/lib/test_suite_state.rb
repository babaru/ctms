class TestSuiteState < ::Settingslogic
  source "#{Rails.root}/config/tms/test_suite_states.yml"
  namespace Rails.env
end
