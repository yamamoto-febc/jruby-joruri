# encoding: utf-8
class Sys::GroupChangeLog < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Tree

  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :parent,  :foreign_key => :parent_id,  :class_name => "#{self}"

  has_many   :children, :foreign_key => :parent_id , :class_name => "#{self}",
    :order => :sort_no, :dependent => :destroy

  validates_presence_of :state, :parent_id, :title

  def self.root_items(conditions = {})
    conditions = conditions.merge({:parent_id => 0, :level_no => 1})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end

  def execute_states
    [['実行可能','standby'],['中間データ作成中','preparing'],['組織反映準備完了','prepared'],['組織反映中','executing'],['組織反映完了','completed']]
  end

  def state_label_name(state)
    execute_states.each {|s| return s[0] if s[1] == state }
  end

  def update_exec_state(state=nil , options={})
    b = if options[:body_add_type] == 'append'
      "#{self.body}\n#{options[:body] || ''}"
    else
      options[:body] || ''
    end

    self.id            = 1
    self.parent_id     = '0'
    self.state         = 'enabled'
    self.level_no      = 1
    self.sort_no       = 0
    self.execute_state = state if state
    self.executed_at   = Core.now
    self.title         = state_label_name(state) if state
    self.body          = b
    save(false)
  end

end
