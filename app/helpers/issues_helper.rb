module IssuesHelper
  def issue_title_with_progress(issue, round = nil)
    [
      issue.list_title,
      issue_progress(issue, round)
    ].join(' ').html_safe
  end

  def issue_progress(issue, round)
    return nil unless round
    return nil if issue.scenarios.count == 0
    content_tag(:span, "(#{Execution.executed(round, issue).count}/#{issue.scenarios.count}) #{Execution.executed(round, issue).count * 100 / issue.scenarios.count}%", class: 'label label-default')
  end
end
