ActionController::Routing::Routes.draw do |map|
  mod = "faq"
  
  ## admin
  map.namespace(mod, :namespace => '') do |ns|
    ns.resources :categories,
      :controller  => "admin/categories",
      :path_prefix => "/_admin/#{mod}/:content/:parent"
    ns.resources :docs,
      :controller  => "admin/docs",
      :path_prefix => "/_admin/#{mod}/:content"
    ns.resources :edit_docs,
      :controller  => "admin/docs/edit",
      :path_prefix => "/_admin/#{mod}/:content"
    ns.resources :recognize_docs,
      :controller  => "admin/docs/recognize",
      :path_prefix => "/_admin/#{mod}/:content"
    ns.resources :publish_docs,
      :controller  => "admin/docs/publish",
      :path_prefix => "/_admin/#{mod}/:content"
    ns.resources :inline_files,
      :controller  => "admin/doc/files",
      :path_prefix => "/_admin/#{mod}/:content/doc/:parent",
      :member => {:download => :get}
    
    ## content
    ns.resources :content_base,
      :controller => "admin/content/base",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :content_settings,
      :controller => "admin/content/settings",
      :path_prefix => "/_admin/#{mod}/:content"
    
    ## node
    ns.resources :node_docs,
      :controller  => "admin/node/docs",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :node_recent_docs,
      :controller  => "admin/node/recent_docs",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :node_search_docs,
      :controller  => "admin/node/search_docs",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :node_tag_docs,
      :controller  => "admin/node/tag_docs",
      :path_prefix => "/_admin/#{mod}/:parent"
    ns.resources :node_categories,
      :controller  => "admin/node/categories",
      :path_prefix => "/_admin/#{mod}/:parent"
    
    ## piece
    ns.resources :piece_recent_docs,
      :controller  => "admin/piece/recent_docs",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :piece_search_docs,
      :controller  => "admin/piece/search_docs",
      :path_prefix => "/_admin/#{mod}"
    ns.resources :piece_categories,
      :controller  => "admin/piece/categories",
      :path_prefix => "/_admin/#{mod}"
  end

  ## public
  map.namespace(mod, :namespace => '', :path_prefix => '/_public') do |ns|
    ns.connect "node_docs/:name/index.html",
      :controller => "public/node/docs",
      :action     => :show
    ns.connect "node_docs/:name/files/:file.:format",
      :controller => "public/node/doc/files",
      :action     => :show
    ns.connect "node_docs/index.:format",
      :controller => "public/node/docs",
      :action     => :index
    ns.connect "node_recent_docs/index.:format",
      :controller => "public/node/recent_docs",
      :action     => :index
    ns.connect "node_search_docs/index.:format",
      :controller => "public/node/search_docs",
      :action     => :index
    ns.connect "node_tag_docs/:tag",
      :controller => "public/node/tag_docs",
      :action     => :index
    ns.connect "node_tag_docs/index.:format",
      :controller => "public/node/tag_docs",
      :action     => :index
    ns.connect "node_categories/:name/:attr/index.:format",
      :controller => "public/node/categories",
      :action     => :show_attr
    ns.connect "node_categories/:name/:file.:format",
      :controller => "public/node/categories",
      :action     => :show
    ns.connect "node_categories/index.html",
      :controller => "public/node/categories",
      :action     => :index
  end
end
