module ScenariosHelper
  def scenario_labels(scenario)
    scenario.labels.inject([]) do |list, label|
      list << content_tag(:span, label.name, class: 'badge badge-info')
    end.join(' ').html_safe
  end
end
