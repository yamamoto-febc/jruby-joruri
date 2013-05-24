# encoding: utf-8
class Faq::GroupChange::Tag < Sys::GroupChangeItem

  belongs_to :entity,     :foreign_key => :item_id,  :class_name => 'Faq::Tag'
  belongs_to :entity_doc, :primary_key => :unid, :foreign_key => :item_unid, :class_name => 'Faq::Doc'

  def entity_cls_name
    Faq::Tag.name
  end


  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Faq::Tag.new
    if t.include?('word')
      item.or 'word', 'LIKE', "%#{change.old_name}%"
      item.or 'word', 'LIKE', "%#{change.old_email}%" if !change.old_email.blank? && change.old_email != change.email
    end
    item.order "updated_at DESC, unid, name"

    tags = item.find(:all)
    transcribe_data tags
  end

  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } , :order => 'id').each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

          if org.word && t.include?('word')
            #name
            org.word = org.word.gsub(/#{change.old_name}/, change.name)
            #email
            org.word = org.word.gsub(/#{change.old_email}/, change.email) unless change.old_email.blank?
          end
        end
      end
      org.save(false) if org.changed?
    end
  end

end
