# encoding: utf-8
class Cms::Public::Node::PreviewController < Cms::Controller::Public::Base
  def index
    ## only preview
    return http_error(404) if Core.mode != 'preview'
    return http_error(404) if !params[:layout_id]
    return http_error(404) if params[:path].join("/") !~ /\*\.html(|\.r)$/
    
    layout = Cms::Layout.find(params[:layout_id])
    return http_error(404) if !layout.concept
    
    @item = Page.site.root_node
    @item.concept_id  = layout.concept_id
    Page.current_node = @item
    Page.current_node = @item
    Page.title        = @item.title
    
    content  = '<div style="padding: 80px 10px; border: 8px solid #eee; color: #aaa; font-weight: bold; text-align: center;">'
    content += 'コンテンツ</div>'
    render :inline => content
  end
end
