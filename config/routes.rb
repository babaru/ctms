Rails.application.routes.draw do

  root 'dashboard#index'

  post 'sync_projects_from_gitlab' => 'projects#sync_from_gitlab', as: :sync_projects_from_gitlab
  post 'sync_issues_from_gitlab' => 'issues#sync_from_gitlab', as: :sync_issues_from_gitlab

  get 'dashboard/index', as: :dashboard

  post 'projects/:id/watch' => 'projects#watch', as: :watch_project
  post 'plans/:id/finish' => 'plans#finish', as: :finish_plan

  resources :projects do
    resources :issues, :milestones
  end

  resources :issues do
    resources :scenarios
  end

  resources :scenarios, :milestones

  resources :plans do
    resources :executions
  end
end
