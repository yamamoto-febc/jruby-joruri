# encoding: utf-8
class Cms::GroupChange::Layout < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Cms::Layout'

  def entity_cls_name
    Cms::Layout.name
  end

  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Cms::Layout.new
    item.or 'title', 'LIKE', "%#{change.old_name}%" if t.include?('title')
    if t.include?('body')
      item.or 'body', 'LIKE', "%#{change.old_name}%"
      item.or 'body', 'LIKE', "%#{change.old_email}%" if !change.old_email.blank? && change.old_email != change.email
      item.or 'body', 'LIKE', "%#{change.old_uri}%"   if !change.old_uri.blank? && change.old_uri != change.new_uri
    end
    if t.include?('mobile_body')
      item.or 'mobile_body', 'LIKE', "%#{change.old_name}%"
      item.or 'mobile_body', 'LIKE', "%#{change.old_email}%" if !change.old_email.blank? && change.old_email != change.email
      item.or 'mobile_body', 'LIKE', "%#{change.old_uri}%"   if !change.old_uri.blank? && change.old_uri != change.new_uri
    end
    if t.include?('smart_phone_body')
      item.or 'smart_phone_body', 'LIKE', "%#{change.old_name}%"
      item.or 'smart_phone_body', 'LIKE', "%#{change.old_email}%" if !change.old_email.blank? && change.old_email != change.email
      item.or 'smart_phone_body', 'LIKE', "%#{change.old_uri}%"   if !change.old_uri.blank? && change.old_uri != change.new_uri
    end
    item.order "concept_id, name, updated_at DESC"
    layouts = item.find(:all)

    transcribe_data layouts
  end


  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } , :order => 'id').each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')
          org.title = org.title.gsub(/#{change.old_name}/, change.name) if org.title && t.include?('title')
          if org.body && t.include?('body')
            #name
            org.body = org.body.gsub(/#{change.old_name}/, change.name)
            #email
            org.body = org.body.gsub(/#{change.old_email}/, change.email) unless change.old_email.blank?
            #url
            org.body = org.body.gsub(/<a (.*?)href="#{change.old_uri}/i, '<a \1href="' + change.new_uri)  if !change.old_uri.blank? && (change.old_uri != change.new_uri)
          end
          if org.mobile_body && t.include?('mobile_body')
            #name
            org.mobile_body = org.mobile_body.gsub(/#{change.old_name}/, change.name)
            #email
            org.mobile_body = org.mobile_body.gsub(/#{change.old_email}/, change.email) unless change.old_email.blank?
            #url
            org.mobile_body = org.mobile_body.gsub(/<a (.*?)href="#{change.old_uri}/i, '<a \1href="' + change.new_uri)   if !change.old_uri.blank? && (change.old_uri != change.new_uri)
          end
          if org.smart_phone_body && t.include?('smart_phone_body')
            #name
            org.smart_phone_body = org.smart_phone_body.gsub(/#{change.old_name}/, change.name)
            #email
            org.smart_phone_body = org.smart_phone_body.gsub(/#{change.old_email}/, change.email) unless change.old_email.blank?
            #url
            org.smart_phone_body = org.smart_phone_body.gsub(/<a (.*?)href="#{change.old_uri}/i, '<a \1href="' + change.new_uri)   if !change.old_uri.blank? && (change.old_uri != change.new_uri)
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
