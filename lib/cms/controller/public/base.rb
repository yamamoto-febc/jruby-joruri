class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout
  layout  'base'
  before_filter :initialize_params
  after_filter :render_public_variables
  after_filter :render_public_layout
  
  def initialize_params
    if !Core.user
      user = Sys::User.new
      user.id = 0
      Core.user = user
    end
    if !Core.user_group
      group = Sys::Group.new
      group.id = 0
      Core.user_group = group
    end
    
    #params.delete(:page)
    if Page.uri =~ /\.p[0-9]+\.html$/
      page = Page.uri.gsub(/.*\.p([0-9]+)\.html$/, '\\1')
      params[:page] = page.to_i if page !~ /^0+$/
    end
  end
  
  def pre_dispatch
    ## each processes before dispatch
  end
  
  def render_public_variables
    
  end
end
