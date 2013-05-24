# encoding: utf-8
class Sys::GroupChange < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::GroupChange::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  belongs_to :old_group, :primary_key => :code, :foreign_key => :old_code, :class_name => 'Sys::Group'
  belongs_to :group, :primary_key => :code, :foreign_key => :code, :class_name => 'Sys::Group'
  belongs_to :temp_group, :primary_key => :group_change_id, :foreign_key => :id, :class_name => 'Sys::GroupChangeGroup'
  belongs_to :layout    , :foreign_key => :layout_id, :class_name => 'Cms::Layout'


  attr_accessor :csv_file, :csv_state, :selector

  validates_presence_of :change_division, :parent_code, :parent_name, :code, :name, :name_en
  validates_presence_of :ldap,
    :if => %Q(change_division == "add" || change_division == "move" || change_division == "integrate")
  validate :validate_old_group,
    :if => %Q(change_division == "move" || change_division == "integrate")
  validate :validate_consistency,
    :if => %Q(change_division != '' && change_division != "keep")

  def validate_old_group
    if old_id.blank?
      errors.add_on_empty :old_id
    elsif !old = Sys::Group.find_by_id(old_id)
      errors.add :old_id, "に該当する組織は存在しません。"
    else
      self.old_id        = old.id
      self.old_code      = old.code
      self.old_name      = old.name
      self.old_name_en   = old.name_en
      self.old_email     = old.email
      self.old_layout_id = old.layout_id
    end
  end

  def validate_consistency
    errors.add :code, "が不正です。" if !parent_code.blank? && !code.blank? && parent_code == code

    if t = Sys::Group.find_by_code(code)
      errors.add :code, "が不正です。" if t.level_no <= 1
    end
  end

  def change_divisions
    [['新設','add'],['移動','move'],['統合','integrate'],['廃止','dismantle'], ['変更なし','keep']]
  end

  def ldap_states
    [['同期',1],['非同期',0]]
  end

  def change_division_label
    change_divisions.each do |kbn|
      return kbn[0] if self.change_division == kbn[1]
    end
  end

  def ldap_label
    ldap_states.each {|a| return a[0] if a[1] == ldap }
    return nil
  end

  def default_order
    self.order "(case change_division" +
      " when 'add' then 1 when 'rename' then 2 when 'move' then 3 when 'integrate' then 4 when 'dismantle' then 5 else 9" +
      " end), parent_code, code"
  end

  def get_article_unit_directory
    return @article_unit_directory if @article_unit_directory
    @article_unit_directory = Cms::Node.find(:first, :conditions => "model = 'Article::Unit'")
  end

  def old_uri
    return nil unless get_article_unit_directory
    "#{get_article_unit_directory.public_uri}" + old_name_en unless old_name_en.blank?
  end

  def new_uri
    return nil unless get_article_unit_directory
    "#{get_article_unit_directory.public_uri}" + name_en.to_s unless name_en.blank?
  end

end
