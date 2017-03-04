Rails.application.routes.draw do
  post 'search_scenarios' => 'scenarios#search', as: :search_scenarios
  post 'search_projects' => 'projects#search', as: :search_projects
  root 'dashboard#index'

  get 'dashboard/index', as: :dashboard

  resources :projects do
    resources :scenarios
  end

  resources :scenarios
end
