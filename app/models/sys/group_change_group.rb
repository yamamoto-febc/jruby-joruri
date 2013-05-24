# encoding: utf-8
class Sys::GroupChangeGroup < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::GroupChange::Base
  include Sys::Model::GroupChange::Temporal

  belongs_to :group_change,  :foreign_key => :group_change_id,   :class_name => 'Sys::GroupChange'
  belongs_to :entity,        :foreign_key => :group_id,          :class_name => 'Sys::Group'
  belongs_to :entity_parent, :foreign_key => :parent_id,         :class_name => 'Sys::Group'


  def pull(change, setting)
    case change.change_division
      when 'add'
        _add_target_group(change)
      when 'rename', 'move'
        _move_target_group(change)
      when 'integrate'
        _integrate_target_group(change)
      when 'dismantle'
        _delete_target_group(change)
      else
        ;
    end
  end

  def synchronize(changes, setting)
    self.class.find(:all, :order => 'id ASC').each do |temp|
      case temp.group_change.change_division
        when 'add'
          _add_group(temp.group_change, temp) unless temp.entity
        when 'rename', 'move'
          _move_group(temp.group_change, temp)
        when 'integrate'
         _integrate_group(temp.group_change, temp)
        when 'dismantle'
          _delete_group(temp.group_change, temp) if temp.entity
        else
          ;
      end if temp.group_change
    end
  end


private
  def _add_target_group(change)
    unless gr = Sys::Group.find_by_code(change.code)
      if p = Sys::Group.find_by_code(change.parent_code)
        temp_g = self.class.new({
          :group_change_id   => change.id,
          :group_id          => nil,
          :parent_id         => p.id,
          :old_group_id      => nil,
        })
        temp_g.save
      end
    end
  end

  def _add_group(change, temp)
    layout_id = (!change.layout_id.blank?) ? change.layout_id : change.old_layout_id

    g = Sys::Group.new({
      :state        => 'enabled',
      :web_state    => 'public',  # or closed
      :created_at   => Core.now,
      :updated_at   => Core.now,
      :parent_id    => temp.parent_id,
      :level_no     => temp.entity_parent.level_no + 1,
      :code         => change.code,
      :sort_no      => change.code.to_s.to_i,
      :layout_id    => layout_id,
      :ldap         => change.ldap,
      :ldap_version => 0,
      :name         => change.name,
      :name_en      => change.name_en,
#     :tel          => '',
#     :outline_uri  => '',
      :email        => change.email
    })
    added_id = g.save_with_direct_sql
    if added_g = Sys::Group.find_by_id(added_id)
      added_g.save_unid
    end
    added_id
  end


  def _move_target_group(change)
    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      unless g = Sys::Group.find(:first, :conditions => {:code => change.code, :name => change.name})
        p_id = nil
        if p = Sys::Group.find_by_code(change.parent_code)
          p_id = p.id
        end

        temp_g = self.class.new({
          :group_change_id   => change.id,
          :group_id          => og.id,
          :parent_id         => p_id,
          :old_group_id      => og.id,
        })
        temp_g.save
      end
    end
  end

  def _move_group(change, temp)
    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      unless g = Sys::Group.find(:first, :conditions => {:code => change.code, :name => change.name})

        update_part = "code = #{self.class.sanitize(change.code)} "
        update_part += ", parent_id = #{self.class.sanitize(temp.parent_id)}" if temp.entity_parent

        sql = "UPDATE #{Sys::Group.table_name} SET #{update_part} WHERE code = #{self.class.sanitize(change.old_code)}"
        Sys::Group.connection.execute(sql)
        g = Sys::Group.find(:first, :conditions => ["code = ? AND 0 = 0", change.code])
      end
      if g
        g.name      = change.name
        g.name_en   = change.name_en
        g.email     = change.email
        g.layout_id = change.layout_id || change.old_layout_id if g.layout_id.blank?
        g.save(false)
      end
    end
  end

  def _integrate_target_group(change)
    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      g_id = nil
      if g = Sys::Group.find(:first, :conditions => {:code => change.code, :name => change.name})
        g_id = g.id
      end
      p_id = nil
      if p = Sys::Group.find_by_code(change.parent_code)
        p_id = p.id
      end

      temp_g = self.class.new({
        :group_change_id   => change.id,
        :group_id          => g_id,
        :parent_id         => p_id,
        :old_group_id      => og.id,
      })
      temp_g.save
    end
  end

  def _integrate_group(change, temp)
    if og = Sys::Group.find(:first, :conditions => {:code => change.old_code, :name => change.old_name})
      g_new_id = nil
      if integ = Sys::Group.find(:first, :conditions => {:code => change.code, :name => change.name})
        if integ.layout_id.blank?
            integ.layout_id = (!change.layout_id.blank?) ? change.layout_id : change.old_layout_id
            integ.save
        end
        g_new_id = integ.id
      else
        g_new_id = _add_group(change, temp)
      end
      if g_new_id
        sql = "UPDATE #{Sys::UsersGroup.table_name} SET group_id = #{g_new_id} WHERE group_id = #{og.id}"
        Sys::UsersGroup.connection.execute(sql)
      end
      og.destroy if og.name == change.old_name && og.code == change.old_code
    end
  end

  def _delete_target_group(change)
    if og = Sys::Group.find(:first, :conditions => {:code => change.code, :name => change.name})
      if p = Sys::Group.find_by_code(change.parent_code)
        if og.parent && og.parent.id == p.id
          temp_g = self.class.new({
            :group_change_id   => change.id,
            :group_id          => og.id,
            :parent_id         => p.id,
            :old_group_id      => nil,
          })
          temp_g.save
        end
      end
    end
  end

  def _delete_group(change, temp)
    temp.entity.destroy if temp.entity.name == change.name && temp.entity.code == change.code
  end

end
