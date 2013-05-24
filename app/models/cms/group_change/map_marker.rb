# encoding: utf-8
class Cms::GroupChange::MapMarker < Sys::GroupChangeItem

  belongs_to :entity_map, :foreign_key => :parent_item_id, :class_name => 'Cms::Map'
  belongs_to :temp_map,   :foreign_key => :parent_item_id, :class_name => "#{self.class.name}", :conditions => "model = 'Cms::Map'"


  def entity
    return @entity if @entity
    @entity = nil
    if item_id >= 0
      @entity = Cms::MapMarker.find(:first, :conditions => {:id => item_id} )
    else
      if map = Cms::Map.new.find(:first, :conditions => {:id => parent_item_id} )
        @entity = Cms::MapMarker.new({
          :map_id   => map.id,
          :sort_no  => item_id.abs,
          :name     => map.send("point#{item_id.abs}_name"),
          :lat      => map.send("point#{item_id.abs}_lat"),
          :lng      => map.send("point#{item_id.abs}_lng"),
        })
      end
    end
    @entity
  end


  def entity_cls_name
    Cms::MapMarker.name
  end


  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Cms::MapMarker.new
    item.or "#{Cms::MapMarker.table_name}.name", 'LIKE', "%#{change.old_name}%" if t.include?('name')
    item.order 'map_id, sort_no'

    markers = item.find(:all)
    transcribe_data markers, {:skip_unid => true, :parent => 'map_id' }


    # cms_maps --
    map = Cms::Map.new
    [1,2,3,4,5].each {|p| map.or "#{Cms::Map.table_name}.point#{p}_name", 'LIKE', "%#{change.old_name}%"} if t.include?('name')
    map.order :id

    maps = map.find(:all)
    maps.each do |m|
      dummy_ids = []
      markers   = []
      srt = 0
      [1,2,3,4,5].each do |p|
        if m.send("point#{p}_name") =~ /#{change.old_name}/
          dummy_ids << -p
          markers << Cms::MapMarker.new({
            :map_id   => m.id,
            :sort_no  => srt,
            :name     => m.send("point#{p}_name"),
            :lat      => m.send("point#{p}_lat"),
            :lng      => m.send("point#{p}_lng"),
          })
        end
        srt += 1
      end
      transcribe_data markers, {:dummy_ids => dummy_ids,  :skip_unid => true, :parent => 'map_id' }
    end
  end


  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } ).each do |temp|
      if temp.item_id >= 0
        # default
        if org = temp.entity
          changes.each do |change|
            next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')
            org.name = org.name.gsub(/#{change.old_name}/, change.name) if org.name && t.include?('name')
          end
          begin
            org.save(false)
          rescue
          end if org.changed?
        end

      else
        # dummy(cms_maps)
        if map = Cms::Map.new.find(:first, :conditions => {:id => temp.parent_item_id} )
          changes.each do |change|
            next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

            if t.include?('name')
              point_name_value = map.send("point#{temp.item_id.abs}_name")
              eval("map.point#{temp.item_id.abs}_name = #{%q{point_name_value.gsub(/#{change.old_name}/, change.name)}}") if point_name_value
            end
          end
        end
        begin
          map.save(false)
        rescue
        end if map.changed?
      end
    end
  end

end
