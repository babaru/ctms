class DashboardPlanGrid
  include Datagrid

  scope do
    Plan.order('plans.id desc')
  end

  column("project-status", header: I18n.t('activerecord.attributes.plan.state')) do |asset|
    format(asset.state) do |value|
      plan_state_label(asset)
    end
  end

  column("title project-title", header: I18n.t('activerecord.attributes.plan.title')) do |asset|
    format(asset.title) do |value|
      [
        link_to(value, plan_path(asset)),
        content_tag(:small, plan_duration_text(asset))
      ].join('<br />').html_safe
    end
  end

  column("project-completion", header: I18n.t('activerecord.attributes.plan.completion')) do |asset|
    format(asset.title) do |value|
      plan_progress(asset)
    end
  end
end
