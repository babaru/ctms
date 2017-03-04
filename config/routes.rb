Rails.application.routes.draw do
  post 'search_projects' => 'projects#search', as: :search_projects
  root 'dashboard#index'

  get 'dashboard/index', as: :dashboard

  resources :projects
end
