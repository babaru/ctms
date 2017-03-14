Rails.application.routes.draw do

  get 'trigger(.:format)' => 'trigger#index', as: :webhook_trigger

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  # devise_scope :user do
  #   delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  # end

  root to: redirect('dashboard')

  post 'sync_projects_from_gitlab' => 'projects#sync_from_gitlab', as: :sync_projects_from_gitlab
  post 'sync_issues_from_gitlab' => 'issues#sync_from_gitlab', as: :sync_issues_from_gitlab

  get 'dashboard', to: 'dashboard#index', as: :dashboard

  post 'projects/:id/watch' => 'projects#watch', as: :watch_project
  post 'plans/:id/finish' => 'plans#finish', as: :finish_plan
  post 'plans/:id/watch' => 'plans#watch', as: :watch_plan
  post 'execute_scenario/:id' => 'scenarios#execute', as: :execute_scenario
  post 'mark_requirement_label/:id' => 'labels#mark_requirement', as: :mark_requirement_label

  get 'executions/:id/new_remark' => 'executions#new_remark', as: :new_execution_remark
  post 'executions/:id/save_remark' => 'executions#save_remark', as: :save_execution_remark

  resources :projects do
    resources :issues, :milestones, :labels
  end

  resources :issues do
    resources :scenarios
  end

  resources :scenarios, :milestones, :labels

  resources :plans do
    resources :executions
  end
end
