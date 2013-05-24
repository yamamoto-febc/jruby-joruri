# encoding: utf-8
class Cms::GroupChange::DataFile < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Cms::DataFile'

  def entity_cls_name
    Cms::DataFile.name
  end

  def pull(change, setting)
    return unless target_cols(setting).include?('title')
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    #title
    cond_old = ["title LIKE :title",
            {:title => "%#{change.old_name}%" } ]

    files = Cms::DataFile.find(:all, :conditions => cond_old, :order => "concept_id, node_id, name, updated_at DESC")
    transcribe_data files
  end


  def synchronize(changes, setting)
    return unless target_cols(setting).include?('title')

    self.class.find(:all, :conditions => { :model => entity_cls_name } , :order => 'id').each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')
          org.title = org.title.gsub(/#{change.old_name}/, change.name) if org.title
        end
      end
      begin
        org.save(false)
      rescue
      end if org.changed?
    end
  end

end
