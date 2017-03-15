class TimeSheet < ApplicationRecord
  belongs_to :user
  belongs_to :issue
  belongs_to :project

  def self.sync_from_gitlab
    Project.time_tracking.each do |project|
      sync_from_gitlab_by_project(project)
    end
  end

  def self.sync_from_gitlab_by_project(project)
    project.issues.each do |issue|
      sync_from_gitlab_by_issue(issue)
    end
  end

  def self.sync_from_gitlab_by_issue(issue)
    TimeSheet.where(issue: issue).destroy_all
    GitLabAPI.instance.notes(issue.project.gitlab_id, issue.gitlab_id).each do |data|
      user = User.from_gitlab_data(data["author"])
      parse_issue_note(data["body"]) do |matched, spent, spent_at|
        TimeSheet.create(user: user, project: issue.project, issue: issue, spent: spent, spent_at: spent_at) if matched
      end
    end
  end

  def self.parse_issue_note(note)
    matched = false
    spent = 0
    spent_at = ''
    if note
      note_parts = note.gsub(/\s+/, ' ').downcase.split(' ')
      matched = (note_parts[0] == 'timesheet')
      if matched
        spent = note_parts[2].gsub('h', '')
        spent_at = note_parts[1]
      end
    end
    yield(matched, spent, spent_at) if block_given?
  end

  def self.user_hours(user, day = nil, month = Time.current.month, year = Time.current.year)
    start_day = day
    end_day = day
    if day.nil?
      start_day = 1
      end_day = Time.days_in_month(month, year)
    end
    hours = TimeSheet.where(
      user: user,
      spent_at: (Time.new(year, month, start_day).beginning_of_day..Time.new(year, month, end_day).end_of_day)).inject(0) do |sum, ts|
        sum = sum + ts.spent
      end
    hours > 0 ? hours : nil
  end

  def self.project_hours(user, project, day = nil, month = Time.current.month, year = Time.current.year)
    start_day = day
    end_day = day
    if day.nil?
      start_day = 1
      end_day = Time.days_in_month(month, year)
    end
    hours = TimeSheet.where(
      user: user,
      project: project,
      spent_at: (Time.new(year, month, start_day).beginning_of_day..Time.new(year, month, end_day).end_of_day)).inject(0) do |sum, ts|
        sum = sum + ts.spent
      end
    hours > 0 ? hours : nil
  end

  def self.issue_hours(user, issue, day = nil, month = Time.current.month, year = Time.current.year)
    start_day = day
    end_day = day
    if day.nil?
      start_day = 1
      end_day = Time.days_in_month(month, year)
    end
    hours = TimeSheet.where(
      user: user,
      issue: issue,
      spent_at: (Time.new(year, month, start_day).beginning_of_day..Time.new(year, month, end_day).end_of_day)).inject(0) do |sum, ts|
        sum = sum + ts.spent
      end
    hours > 0 ? hours : nil
  end
end
