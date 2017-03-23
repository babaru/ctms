Rails.application.routes.draw do

  get 'reporting/time_sheets', as: :time_sheets

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: redirect('dashboard')

  post 'sync_projects_from_gitlab' => 'projects#sync_from_gitlab', as: :sync_projects_from_gitlab
  post 'projects/:id/sync_time_sheets_from_gitlab' => 'projects#sync_time_sheets_from_gitlab', as: :sync_project_time_sheets_from_gitlab
  post 'sync_issues_from_gitlab' => 'issues#sync_from_gitlab', as: :sync_issues_from_gitlab
  post 'issues/:id/sync_time_sheets_from_gitlab' => 'issues#sync_time_sheets_from_gitlab', as: :sync_issue_time_sheets_from_gitlab
  post 'sync_time_sheets_from_gitlab' => 'time_sheets#sync_from_gitlab', as: :sync_time_sheets_from_gitlab

  get 'dashboard', to: 'dashboard#index', as: :dashboard

  post 'projects/:id/watch' => 'projects#watch', as: :watch_project

  post 'plans/:id/complete' => 'plans#complete', as: :complete_plan
  post 'plans/:id/watch' => 'plans#watch', as: :watch_plan
  post 'mark_requirement_label/:id' => 'labels#mark_requirement', as: :mark_requirement_label
  post 'set_defect_label/:id' => 'labels#set_defect', as: :set_defect_label
  post 'reset_defect_label/:id' => 'labels#reset_defect', as: :reset_defect_label

  post 'execute_scenario/:id' => 'executions#execute', as: :execute_scenario
  get 'executions/:id/remarks' => 'executions#remarks', as: :execution_remarks
  post 'executions/:id/post_remarks' => 'executions#post_remarks', as: :post_execution_remarks
  post 'executions/:id/delete_remarks' => 'executions#delete_remarks', as: :execution_delete_remarks

  post 'trigger(.:format)' => 'trigger#index', as: :webhook_trigger

  post 'users/:id/time_tracking' => 'users#time_tracking', as: :user_time_tracking
  post 'projects/:id/time_tracking' => 'projects#time_tracking', as: :project_time_tracking

  post 'rounds/:id/complete' => 'rounds#complete', as: :complete_round

  get 'new_defect' => 'issues#new_defect', as: :new_defect
  post 'create_defect' => 'issues#create_defect', as: :create_defect

  resources :projects do
    resources :issues, :milestones, :labels
  end

  resources :issues do
    resources :scenarios
  end

  resources :scenarios, :milestones, :labels

  resources :plans do
    resources :rounds
  end

  resources :rounds do
    resources :executions
  end

  resources :users
end
