# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  #navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'active'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  #navigation.active_leaf_class = 'simple-navigation-active-leaf'

  # Specify if item keys are added to navigation items as id. Defaults to true
  #navigation.autogenerate_item_ids = true

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  #navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that
  # will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  #navigation.name_generator = Proc.new {|name, item| "<span>#{name}</span>"}

  # Specify if the auto highlight feature is turned on (globally, for the whole navigation). Defaults to true
  navigation.auto_highlight = true
  navigation.highlight_on_subpath = true

  # Specifies whether auto highlight should ignore query params and/or anchors when
  # comparing the navigation items with the current URL. Defaults to true
  # navigation.ignore_query_params_on_auto_highlight = true
  # navigation.ignore_anchors_on_auto_highlight = true

  # If this option is set to true, all item names will be considered as safe (passed through html_safe). Defaults to false.
  #navigation.consider_item_names_as_safe = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>if: -> { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>unless: -> { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    # primary.item :dashboard, t('navigation.pages.dashboard'), dashboard_url, html: { icon: 'dashboard' }

    primary.item :projects, t('navigation.pages.projects'), 'javascript:void(0);', highlights_on: :subpath, html: { icon: 'folder' } do |projects|
      projects.item :all_projects, t('navigation.pages.projects_list'), projects_path

      Project.watched(current_user).each do |project|
        projects.item "project_#{project.id}".to_sym, project.title, project_path(project)
      end
    end

    primary.item :plans, t('navigation.pages.plans'), 'javascript:void(0);', highlights_on: :subpath, html: { icon: 'file-movie-o' } do |plans|
      plans.item :all_plans, t('navigation.pages.plans_list'), plans_path

      Plan.watched(current_user).each do |plan|
        plans.item "plan_#{plan.id}".to_sym, plan.title, plan_path(plan)
      end
    end

    primary.item :users, t('navigation.pages.users'), 'javascript:void(0);', highlights_on: :subpath, html: { icon: 'users' } do |users|
      users.item :all_users, t('navigation.pages.users_list'), users_path
    end

    primary.item :reporting, t('navigation.pages.reporting'), nil, highlights_on: /reporting/, html: { icon: 'newspaper-o' } do |reporting|
      reporting.item :time_sheets, t('navigation.pages.time_sheets'), time_sheets_path
    end

    # primary.item :bugs, t('navigation.pages.bugs'), 'javascript:void(0);', highlights_on: :subpath, html: { icon: 'bug' }
    # primary.item :tickets, t('navigation.pages.tickets'), 'javascript:void(0);', highlights_on: :subpath, html: { icon: 'ticket' }

    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    #primary.dom_attributes = {id: 'menu-id', class: 'menu-class'}

    # You can turn off auto highlighting for a specific level
    #primary.auto_highlight = false
  end
end
