# encoding: utf-8
class Cms::GroupChange::Map < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Cms::Map'

  def entity_cls_name
    Cms::Map.name
  end

  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Cms::Map.new
    #item.join "INNER JOIN #{Sys::Unid.table_name} ON #{Sys::Unid.table_name}.id = #{Cms::Map.table_name}.unid"
    #item.and  "#{Sys::Unid.table_name}.model", 'Article::Doc'
    item.or  "#{Cms::Map.table_name}.title", 'LIKE', "%#{change.old_name}%" if t.include?('title')
#    if t.include?('point_name')
#      item.or  "#{Cms::Map.table_name}.point1_name", 'LIKE', "%#{change.old_name}%"
#      item.or  "#{Cms::Map.table_name}.point2_name", 'LIKE', "%#{change.old_name}%"
#      item.or  "#{Cms::Map.table_name}.point3_name", 'LIKE', "%#{change.old_name}%"
#      item.or  "#{Cms::Map.table_name}.point4_name", 'LIKE', "%#{change.old_name}%"
#      item.or  "#{Cms::Map.table_name}.point5_name", 'LIKE', "%#{change.old_name}%"
#    end
    item.order 'title, updated_at DESC'

    maps = item.find(:all)
    transcribe_data maps
  end

  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } ).each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

          org.title = org.title.gsub(/#{change.old_name}/, change.name) if org.title && t.include?('title')
#          if t.include?('point_name')
#            org.point1_name = org.point1_name.gsub(/#{change.old_name}/, change.name) if org.point1_name
#            org.point2_name = org.point2_name.gsub(/#{change.old_name}/, change.name) if org.point2_name
#            org.point3_name = org.point3_name.gsub(/#{change.old_name}/, change.name) if org.point3_name
#            org.point4_name = org.point4_name.gsub(/#{change.old_name}/, change.name) if org.point4_name
#            org.point5_name = org.point5_name.gsub(/#{change.old_name}/, change.name) if org.point5_name
#          end
        end
      end
      begin
        org.save(false)
      rescue
      end if org.changed?
    end
  end

end
