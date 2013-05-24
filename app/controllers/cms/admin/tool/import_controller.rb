# encoding: utf-8
class Cms::Admin::Tool::ImportController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @results = []
    
    @item = Cms::Model::Tool::Import.new
    return unless request.post?
    
    @item.attributes = params[:item]
    return unless @item.valid?
    
    ## concept
    @concept = Cms::Concept.find_by_id(@item.concept_id)
    return unless @concept
    
    #import = ActiveSupport::JSON.decode @item.file.read
    require "json"
    import = JSON.parse @item.file.read
    @results << "インポートを開始しました。"
    
    ## layouts
    @results << "" << "-- レイアウト"
    
    import['layouts'].each do |json|
      json   = json['layout']
      data   = json['layout']
      name   = data['name']
      state  = data[:state]
      
      cond   = {:name => name, :concept_id => @concept.id}
      item   = Cms::Layout.find(:first, :conditions => cond) || Cms::Layout.new
      exists = item.id ? true : false
      
      data.delete('id')
      data.delete('unid')
      data.delete('site_id')
      data.delete('concept_id')
      data.delete('state')
      data.delete('recognized_at')
      data.delete('published_at')
      
      item.attributes   = data
      item.site_id    ||= Core.site.id
      item.concept_id ||= @concept.id
      item.state      ||= (state || 'closed')
      
      if !item_changed?(item)
        #
      elsif item.save
        item.put_css_files if item.state == "public"
        action = exists ? "を更新しました。" : "を登録しました。"
        @results << "#{name} #{action}" 
      else
        action = exists ? "の更新に失敗しました。" : "の登録に失敗しました。"
        @results << "#{name} #{action} (#{item.errors.full_messages.join(' ')})" 
      end
    end if import['layouts'].size > 0
    
    ## pieces
    @results << "" << "-- ピース"
    
    import['pieces'].each do |json|
      data   = json['piece']['piece']
      name   = data['name']
      state  = data[:state]
      
      cond   = {:name => name, :concept_id => @concept.id}
      piece  = Cms::Piece.find(:first, :conditions => cond) || Cms::Piece.new
      exists = piece.id ? true : false
      
      data.delete('id')
      data.delete('unid')
      data.delete('site_id')
      data.delete('concept_id')
      data.delete('content_id')
      data.delete('recognized_at')
      data.delete('published_at')
      
      piece.attributes   = data
      piece.site_id    ||= Core.site.id
      piece.concept_id ||= @concept.id
      
      ## content
      concept = nil
      content = nil
      if json['content'] && json['content_concepts']
        parent  = 0
        json['content_concepts'].each do |name|
          cond    = {:parent_id => 0, :name => name}
          concept = Cms::Concept.find(:first, :conditions => cond)
          break unless concept
          parent  = concept.id
        end
        if concept
          name    = json['content']['content']['name']
          cond    = {:name => name, :concept_id => concept.id}
          content = Cms::Content.find(:first, :conditions => cond)
        end
        piece.content_id = content.id if content
      end
      
      changed = item_changed?(piece)
      
      if changed && !piece.save
        action = exists ? "の更新に失敗しました。" : "の登録に失敗しました。"
        @results << "#{piece.name} #{action} (#{piece.errors.full_messages.join(' ')})"
        next
      end 
      
      ## setting
      json['settings'].each do |data|
        data = data['piece_setting']
        cond = {:piece_id => piece.id, :name => data['name']}
        item = Cms::PieceSetting.find(:first, :conditions => cond) || Cms::PieceSetting.new
        item.piece_id  = piece.id
        item.name      = data['name']
        item.value     = data['value']
        item.sort_no ||= data['sort_no']
        if item_changed?(item)
          item.save
          changed = true
        end
      end if json['settings']
      
      ## links
      json['link_items'].each do |data|
        data = data['piece_link_item']
        cond = {:piece_id => piece.id, :name => data['name']}
        item = Cms::PieceLinkItem.find(:first, :conditions => cond) || Cms::PieceLinkItem.new
        item.piece_id  = piece.id
        item.state     = data['state']
        item.name      = data['name']
        item.body      = data['body']
        item.uri       = data['uri']
        item.target    = data['target']
        item.sort_no ||= data['sort_no']
        if item_changed?(item)
          item.save
          changed = true
        end
      end if json['link_items']
      
      if changed
        action = exists ? "を更新しました。" : "を登録しました。"
        @results << "#{piece.name} #{action}" 
      end
    end if import['pieces'].size> 0
  end
  
protected
  def item_changed?(item)
    return false if !item.changed?
    changed = item.changed
    changed.delete('updated_at')
    return changed.size > 0
  end
end
