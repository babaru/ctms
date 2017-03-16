namespace :nightly do
  task sync_from_gitlab: :environment do
    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
    end

    Project.sync_from_gitlab

    projects = []

    User.all.each do |user|
      Project.watched(user).each do |project|
        unless projects.include?(project.id)
          Rails.logger.info "Syncing project [#{project.title}] issues"
          Issue.sync_from_gitlab(project)
          projects << project.id
        end
      end
    end

    Project.time_tracking.each do |project|
      Rails.logger.info "Syncing project [#{project.title}] time sheets"
      TimeSheet.sync_from_gitlab_by_project(project)
    end
  end
end
