Rails.application.routes.draw do

  post 'issues/search' => 'issues#search', as: :search_issues
  post 'milestones/search' => 'milestones#search', as: :search_milestones
  post 'search_scenarios' => 'scenarios#search', as: :search_scenarios
  post 'search_projects' => 'projects#search', as: :search_projects
  root 'dashboard#index'

  post 'sync_projects_from_gitlab' => 'projects#sync_from_gitlab', as: :sync_projects_from_gitlab
  post 'sync_issues_from_gitlab' => 'issues#sync_from_gitlab', as: :sync_issues_from_gitlab

  get 'dashboard/index', as: :dashboard

  post 'projects/:id/watch'=> 'projects#watch', as: :watch_project

  resources :projects do
    resources :issues, :milestones
  end

  resources :issues do
    resources :scenarios
  end

  resources :scenarios, :milestones
end
