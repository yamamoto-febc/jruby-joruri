# encoding: utf-8
class Article::GroupChange::MapMarker < Cms::GroupChange::MapMarker

  #belongs_to :entity_doc, :primary_key => :unid, :foreign_key => :item_unid, :class_name => 'Article::Doc'
  def entity_doc
    return @entity_doc if @entity_doc
    if p = entity_map
      @entity_doc = Article::Doc.find(:first, :conditions => {:unid => p.unid })
    else
      @entity_doc = nil
    end
    @entity_doc
  end

  def owner_entity_cls_name
    Article::Doc.name
  end

end
