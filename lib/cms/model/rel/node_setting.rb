module Cms::Model::Rel::NodeSetting
  def self.included(mod)
    mod.has_many   :settings, :foreign_key => :node_id,   :class_name => 'Cms::NodeSetting',
      :order => :sort_no, :dependent => :destroy
    
    mod.after_save :save_settings
  end

  attr_accessor :in_settings
  
  def in_settings
    unless read_attribute(:in_settings)
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = st.value
        else
          values[st.name] = st.value
        end
      end
      write_attribute(:in_settings, values)
    end
    read_attribute(:in_settings)
  end
  
  def in_settings=(values)
    write_attribute(:in_settings, values)
  end
  
  def new_setting(name = nil)
    Cms::NodeSetting.new({:node_id => id, :name => name.to_s})
  end
  
  def setting_value(name, default_value = nil)
    st = settings.find(:first, :conditions => {:name => name.to_s})
    return default_value unless st
    return st.value.blank? ? default_value : st.value
  end
  
  def save_settings
    in_settings.each do |name, value|
      name = name.to_s
      
      if !value.is_a?(Hash)
        st = settings.find(:first, :conditions => ["name = ?", name]) || new_setting(name)
        st.value   = value
        st.sort_no = nil
        st.save if st.changed?
        next
      end
      
      _settings = settings.find(:all, :conditions => ["name = ?", name])
      value.each_with_index do |data, idx|
        st = _settings[idx] || new_setting(name)
        st.sort_no = data[0]
        st.value   = data[1]
        st.save if st.changed?
      end
      (_settings.size - value.size).times do |i|
        idx = value.size + i - 1
        _settings[idx].destroy
        _settings.delete_at(idx)
      end
    end
    return true
  end
  
end