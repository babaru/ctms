class TimeSheet < ApplicationRecord
  belongs_to :user
  belongs_to :issue
  belongs_to :project

  def self.sync_from_gitlab(month = Time.current.month, year = Time.current.year)
    TimeSheet.where(spent_at: (Time.new(year, month, 1)..Time.new(year, month, Time.days_in_month(month, year)))).destroy_all
    Project.time_tracking.each do |project|
      project.issues.each do |issue|
        GitLabAPI.instance.notes(project, issue).each do |data|
          user = User.from_gitlab_data(data["author"])
          matched, spent, spent_at = parse_issue_note(data["body"], month, year)
          TimeSheet.create(user: user, project: project, issue: issue, spent: spent, spent_at: spent_at) if matched
        end
      end
    end
  end

  def self.parse_issue_note(note, month = Time.current.month, year = Time.current.year)
    [false, 0, Time.now]
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
