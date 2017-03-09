module ProjectsHelper
  def scenarios_tree(issue)
    content_tag(:ul,
      issue.scenarios.inject([]){|list, s| list << content_tag(:li, s.title, data: {jstree: 'scenario'})}.join.html_safe)
  end
end
