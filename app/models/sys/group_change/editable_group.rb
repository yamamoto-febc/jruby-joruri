class Sys::GroupChange::EditableGroup < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Sys::EditableGroup'

  def entity_cls_name
    Sys::EditableGroup.name
  end

  def pull(change, setting)
    return unless change.change_division == 'integrate'
    return if change.old_id.blank?

    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      m = Sys::EditableGroup.new
      m.and :group_ids, 'REGEXP', "(^| )#{og.id}( |$)"
      editable_groups = m.find(:all)

      transcribe_data editable_groups, {:skip_unid => true }
    end

  end

  def synchronize(changes, setting)
    self.class.find(:all, :conditions => { :model => entity_cls_name }).each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless change.change_division == 'integrate'
          next if change.old_id.blank?

          new_groups = []
          ids = org.group_ids.to_s.split(' ').uniq
          ids.each do |g|
            if g == change.temp_group.old_group_id.to_s
              new_groups << change.group.id.to_s
            else
              new_groups << g
            end
          end
          org.group_ids = new_groups.uniq.join(' ').strip
          begin
            org.save(false)
          rescue
          end if org.changed?
        end
      end
    end
  end

end
