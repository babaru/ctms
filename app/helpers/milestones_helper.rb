module MilestonesHelper
  def milestone_badge(milestone)
    return nil unless milestone
    content_tag(:span, fa_icon('clock-o', text: milestone.title), class: 'badge badge-default')
  end
end
