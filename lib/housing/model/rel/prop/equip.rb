# encoding: utf-8
module Housing::Model::Rel::Prop::Equip
  attr_accessor :in_equip
  
  def in_equip
    unless val = read_attribute(:in_equip)
      write_attribute(:in_equip, equip.to_s.split(' ').uniq)
    end
    read_attribute(:in_equip)
  end
  
  def in_equip=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      write_attribute(:equip, _ids.join(' '))
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << key unless val.blank? }
      write_attribute(:equip, _ids.join(' '))
    else
      write_attribute(:equip, ids)
    end
  end
  
  def equip_candidates()
    [
      ['TV' ,'tv'],
      ['NET','net'],
      ['TEL','tel'],
    ]
  end
  
  def equip_hash
    hash = {}
    equip_candidates.each do |v, k|
      hash[k] = v if equip.to_s =~ /(^| )#{k}( |$)/
    end
    hash
  end

end