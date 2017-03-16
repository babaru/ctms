namespace :time_sheet do
  task projects: :environment do
    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
    end

    Project.time_tracking.each do |project|
      TimeSheet.sync_from_gitlab_by_project(project)
    end
  end
end
