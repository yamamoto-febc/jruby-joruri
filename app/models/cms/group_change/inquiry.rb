# encoding: utf-8
class Cms::GroupChange::Inquiry < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Cms::Inquiry'

  def entity_cls_name
    Cms::Inquiry.name
  end

  def order_by
    self.order 'owner_model desc, id'
  end

  def entity_parent_info
    if self.owner_model.to_s != ''
      if owner = eval("#{self.owner_model}").find(:first, :conditions => {:unid => item_id})
        return owner.information
      end
    end
    'unknown'
  end

end
