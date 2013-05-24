class Sys::GroupChange::Creator < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Sys::Creator'

  def entity_cls_name
    Sys::Creator.name
  end

  def pull(change, setting)
    return unless change.change_division == 'integrate'

    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      cond = ["group_id = :group_id", {:group_id => og.id } ]
      creators = Sys::Creator.find(:all, :conditions => cond, :order => "updated_at DESC")
      transcribe_data creators, {:skip_unid => true }
    end
  end


  def synchronize(changes, setting)
    self.class.find(:all, :conditions => { :model => entity_cls_name }).each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless change.change_division == 'integrate'
          if (org.group_id == change.temp_group.old_group_id)
            org.group_id = change.group.id
            begin
              org.save(false)
            rescue
            end if org.changed?
          end
        end
      end
    end
  end

end
