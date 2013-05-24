# encoding: utf-8
module Sys::Model::GroupChange::Temporal

  def entity_cls_name
    nil
  end

  def owner_entity_cls_name
    nil
  end

  def pull(change, setting)
    # hoge
  end

  def synchronize(change, setting)
    # hoge
  end

  def add_condition
    self.and :model, entity_cls_name if entity_cls_name
  end

  def order_by
    self.order :id
  end

  def target_cols(setting)
    setting_m = Sys::GroupChangeSetting.config(setting[:id])

    if setting_m.value == nil
      # default --all
      cols = []
      setting[:options].each {|o| cols << o[1] }
      return cols
    elsif setting_m.value == ''
      return [];
    else
      return setting_m.value.split(/ /)
    end
  end


protected
  def transcribe_data(targets, options={})

    cnt = 0
    targets.each do |f|
      entity_id = (options[:dummy_ids] && options[:dummy_ids].size > cnt) ? options[:dummy_ids][cnt] : f.id;
      cond = {:item_id => entity_id, :model => entity_cls_name}
      cond.merge!({:parent_item_id  => eval("f.#{options[:parent]}")}) if options[:parent]

      tmp = self.class.find(:first ,:conditions => cond)
      tmp ||= self.class.new
      tmp.item_id        = entity_id
      tmp.item_unid      = options[:skip_unid] ? -1 : f.unid;
      tmp.parent_item_id = options[:parent] ? eval("f.#{options[:parent]}") : -1;
      tmp.model          = entity_cls_name
      tmp.owner_model    = owner_entity_cls_name
      tmp.save

      cnt += 1
    end
  end
end
