# encoding: utf-8
class Article::GroupChange::Map < Cms::GroupChange::Map

  belongs_to :entity_doc, :primary_key => :unid, :foreign_key => :item_unid, :class_name => 'Article::Doc'

end