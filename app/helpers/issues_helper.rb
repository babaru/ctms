module IssuesHelper
  def issue_title_with_progress(issue, round = nil)
    [
      issue.list_title,
      issue_progress(issue, round)
    ].join(' ').html_safe
  end

  def issue_title_with_labels(issue)
    [
      issue.title,
      issue_labels(issue)
    ].join(' ').html_safe
  end

  def issue_list_title_with_labels(issue)
    [
      issue.list_title,
      issue_labels(issue)
    ].join(' ').html_safe
  end

  def issue_labels(issue)
    issue.labels.inject([]) do |list, item|
      list << content_tag(:span, fa_icon('tag', text: item.name), class: 'badge badge-default')
    end.join(' ').html_safe
  end

  def issue_progress(issue, round)
    # return nil unless round
    return nil if issue.scenarios.count == 0
    if round
      content_tag(:span, "(#{Execution.executed(round).where(issue: issue).count}/#{issue.scenarios.count}) #{Execution.executed(round).where(issue: issue).count * 100 / issue.scenarios.count}%", class: 'label label-default')
    else
      content_tag(:span, issue.scenarios.count, class: 'label label-default')
    end
  end

  def issue_state_label(issue)
    return content_tag(:span, issue.state, class: 'label label-info') if issue.opened? || issue.reopened?
    return content_tag(:span, issue.state, class: 'label label-default') if issue.closed?
  end
end
