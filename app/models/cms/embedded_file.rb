class Cms::EmbeddedFile < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  #include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  
  belongs_to :site   , :foreign_key => :site_id   , :class_name => 'Cms::Site'
  
  attr_accessor :in_resize_size, :in_thumbnail_size
  #validates_presence_of :name
  
  before_save :set_published_at
  after_save :upload_public_file
  after_destroy :remove_public_file
  
  def public_path
    return nil unless site
    dir = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_emfiles/#{dir}/#{escaped_name}"
  end
  
  def public_uri
    dir = Util::String::CheckDigit.check(format('%07d', id))
    "/_emfiles/#{dir}/#{escaped_name}"
  end
  
  def public_full_uri
    "#{site.full_uri}#{public_uri.sub(/^\//, '')}"
  end
  
  def public
    self.and :state, 'public'
    self
  end
  
  def set_published_at
    self.published_at = (state == "public") ? Core.now : nil
  end
  
  def upload_public_file
    remove_public_file
    
    if state == "public"
      upl_path = upload_path
      pub_path = public_path
      Util::File.put(pub_path, :src => upl_path, :mkdir => true) if FileTest.exist?(upl_path)
      
      upl_path = ::File.dirname(upload_path) + "/thumb.dat"
      pub_path = ::File.dirname(public_path) + "/thumb/" + ::File.basename(public_uri)
      Util::File.put(pub_path, :src => upl_path, :mkdir => true) if FileTest.exist?(upl_path)
    end
    return true
  end
  
  def remove_public_file
    dir = ::File.dirname(public_path)
    FileUtils.rm_rf(dir) if FileTest.exist?(dir)
    return true
  end
end
