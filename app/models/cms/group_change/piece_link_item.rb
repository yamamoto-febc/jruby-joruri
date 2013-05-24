# encoding: utf-8
class Cms::GroupChange::PieceLinkItem < Sys::GroupChangeItem

  belongs_to :entity,       :foreign_key => :item_id,        :class_name => 'Cms::PieceLinkItem'
  belongs_to :entity_piece, :foreign_key => :parent_item_id, :class_name => 'Cms::Piece'
  belongs_to :temp_piece,   :foreign_key => :parent_item_id, :class_name => "#{self.class.name}", :conditions => "model = 'Cms::Piece'"

  def entity_cls_name
    Cms::PieceLinkItem.name
  end

  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Cms::PieceLinkItem.new
    item.or 'name', 'LIKE', "%#{change.old_name}%" if t.include?('name')
    if t.include?('body')
      item.or 'body', 'LIKE', "%#{change.old_name}%"
      item.or 'body', 'LIKE', "%#{change.old_email}%" if !change.old_email.blank? && change.old_email != change.email
      item.or 'body', 'LIKE', "%#{change.old_uri}%"   if !change.old_uri.blank? && change.old_uri != change.new_uri
    end
    item.or 'uri', 'LIKE', "%#{change.old_uri}%" if !change.old_uri.blank? && change.old_uri != change.new_uri if t.include?('uri')

    item.order "piece_id, uri, updated_at DESC"

    links = item.find(:all)
    transcribe_data links, {:skip_unid => true, :parent => 'piece_id' }
  end

  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } ).each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')
          org.name = org.name.gsub(/#{change.old_name}/, change.name) if org.name && t.include?('name')
          if org.body && t.include?('body')
            #name
            org.body = org.body.gsub(/#{change.old_name}/, change.name)
            #email
            org.body = org.body.gsub(/#{change.old_email}/, change.email) unless change.old_email.blank?
            #url
            org.body = org.body.gsub(/<a (.*?)href="#{change.old_uri}/i, '<a \1href="' + change.new_uri) if !change.old_uri.blank? && (change.old_uri != change.new_uri)
          end
          if org.uri && t.include?('uri')
            #url
            org.uri = org.uri.gsub(/^#{change.old_uri}/i, change.new_uri)  if !change.old_uri.blank? && (change.old_uri != change.new_uri)
          end
        end
      end
      begin
        org.save(false)
      rescue
      end if org.changed?
    end
  end

end
