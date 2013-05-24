# encoding: utf-8
class Cms::GroupChange::NodeInquiry < Cms::GroupChange::Inquiry

  belongs_to :entity_node, :primary_key => :unid, :foreign_key => :item_id, :class_name => 'Cms::Node'

  def owner_entity_cls_name
    Cms::Node.name
  end

  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    if old_group = change.old_group
      inq = Cms::Inquiry.new
      inq.join "INNER JOIN #{Sys::Unid.table_name} ON #{Sys::Unid.table_name}.id = #{Cms::Inquiry.table_name}.id"
      inq.and  "#{Sys::Unid.table_name}.model", owner_entity_cls_name
      #inq.and  "#{Cms::Inquiry.table_name}.charge", "LIKE", "%#{change.old_name}%"
      inq.and  "#{Cms::Inquiry.table_name}.group_id", old_group.id
      inq.order 'group_id, user_id, updated_at DESC'

      inquiries = inq.find(:all)
      transcribe_data inquiries, {:skip_unid => true}
    end
  end

  def synchronize(changes, setting)
    t = target_cols(setting)

    self.class.find(:all, :conditions => { :model => entity_cls_name, :owner_model => owner_entity_cls_name } ).each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

          org.group_id = change.group.id if change.change_division == 'integrate' && change.group

          if (!org.email.blank?) && (!change.old_email.blank?)
            org.email = org.email.gsub(/#{change.old_email}/, change.email)
          end unless t.size == 0
        end
      end
      begin
        org.save(false)
      rescue
      end if org.changed?
    end
  end

end