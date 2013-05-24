ActionController::Routing::Routes.draw do |map|
  mod = "sys"
  
  ## script
  map.namespace(mod, :namespace => '', :path_prefix => '/_script') do |ns|
    ns.connect "run/*paths",
      :controller => "script/runner",
      :action     => :run
  end
  
  ## admin
  map.namespace(mod, :namespace => '') do |ns|
    ns.tests "tests",
      :controller  => "admin/tests",
      :path_prefix => "/_admin/#{mod}"
    ns.tests_mail "tests_mail",
      :controller  => "admin/tests/mail",
      :path_prefix => "/_admin/#{mod}"
    ns.tests_link_check "tests_link_check",
      :controller  => "admin/tests/link_check",
      :path_prefix => "/_admin/#{mod}"
    ns.resource :my_account,
      :controller  => "admin/my_account",
      :path_prefix => "/_admin/#{mod}",
      :collection => [:edit_password, :update_password]
    ns.resources :settings,
      :controller  => "admin/settings",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :maintenances,
      :controller  => "admin/maintenances",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :messages,
      :controller  => "admin/messages",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :languages,
      :controller  => "admin/languages",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :ldap_groups,
      :controller  => "admin/ldap_groups",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :ldap_users,
      :controller  => "admin/ldap_users",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :ldap_synchros,
      :controller  => "admin/ldap_synchros",
      :path_prefix => "/_admin/#{mod}",
      :member      => [:synchronize]
    ns.resources :users,
      :controller  => "admin/users",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :groups,
      :controller  => "admin/groups",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :group_users,
      :controller  => "admin/group_users",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :export_groups,
      :controller  => "admin/groups/export",
      :path_prefix => "/_admin/#{mod}",
      :collection => [:export]
    ns.resources :import_groups,
      :controller  => "admin/groups/import",
      :path_prefix => "/_admin/#{mod}",
      :collection => [:import]
#    ns.resources :roles,
#      :controller  => "admin/roles",
#      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :role_names,
      :controller  => "admin/role_names",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :object_privileges,
      :controller  => "admin/object_privileges",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :inline_files,
      :controller  => "admin/inline/files",
      :path_prefix => "/_admin/#{mod}/:parent",
      :member => {:download => :get}
      
    ns.resources :group_change_temporaries,
      :controller  => "admin/group_change_temporaries",
      :path_prefix => "/_admin/#{mod}/:parent/:current",
      :collection => [:synchronize]
    ns.resources :group_changes,
      :controller  => "admin/group_changes",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :group_change_settings,
      :controller  => "admin/group_change_settings",
      :path_prefix => "/_admin/#{mod}"
  end
    
  map.connect "_admin/#{mod}/:parent/inline_files/files/:name.:format",
    :controller => 'sys/admin/inline/files',
    :action     => 'download'
  map.connect "_admin/#{mod}/:parent/inline_files/files/:type/:name.:format",
    :controller => 'sys/admin/inline/files',
    :action     => 'download'
end
