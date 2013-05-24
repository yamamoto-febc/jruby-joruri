# encoding: utf-8
require 'mime/types'
class Cms::Stylesheet < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Concept
  
  attr_accessor :name, :body, :base_path, :base_uri
  attr_accessor :new_directory, :new_file, :upload
  
  validates_presence_of :name
  validates_format_of :name, :with=> /^[0-9A-Za-z@\.\-\_]+$/, :message=> :not_a_filename
  
  after_destroy :remove_file
  
  def self.new_by_path(path)
    item = self.find_by_path(path) || self.new(:path => path)
    item.base_path = "#{Rails.root}/public/_common/themes"
    item.base_uri  = "/_common/themes/"
    item.name      = ::File.basename(path)
    #item.new_record = params[:new_record] ? true : false
    return item
  end
  
  def concept(reload = nil)
    return @_concept if !reload && @_concept
    if directory?
      @_concept = concept_id ? Cms::Concept.find_by_id(concept_id) : nil
    else
      dir = self.class.new_by_path(::File.dirname(path))
      @_concept = dir ? dir.concept : nil
    end
  end
  
  def upload_path
    ::File.join(base_path, path)
  end
  
  # def public_path
    # ::File.join(base_uri, path)
  # end
  
  def public_uri
    ::File.join(base_uri, path)
  end
  
  def directory?
    ::FileTest.directory?(upload_path)
  end
  
  def file?
    ::FileTest.file?(upload_path)
  end
  
  def textfile?
    return false unless file?
    mime_type.blank? || mime_type =~ /^text/i
  end
  
  def read_stat
    @_stat ||= ::File.stat(upload_path)
    @_stat
  end
  
  def read_body
    self.body = NKF.nkf('-w', ::File.new(upload_path).read.to_s) if textfile?
  rescue Exception
    self.body = "#読み込みに失敗しました。"
  end
  
  def mtime
    read_stat.mtime
  end
  
  def mime_type
    @_mime_type ||= MIME::Types.type_for(upload_path)[0].to_s
    @_mime_type
  end
  
  def type
    return 'text' if mime_type == "text/plain"
    mime_type.gsub(/.*\//, '')
  end
  
  def size(unit = nil)
    stat = read_stat
    if unit == :kb
      (stat.size.to_f/1024).ceil
    else
      stat.size
    end
  end
  
  def child_directories
    items = []
    Dir::entries(upload_path).sort.each do |name|
      next if name =~ /^\.+/
      child_path = ::File.join(upload_path, name)
      next if ::FileTest.file?(child_path)
      items << self.class.new_by_path(::File.join(path, name))
    end
    items
  end
  
  def child_files
    items = []
    Dir::entries(upload_path).sort.each do |name|
      next if name =~ /^\.+/
      child_path = ::File.join(upload_path, name)
      next if ::FileTest.directory?(child_path)
      items << self.class.new_by_path(::File.join(path, name))
    end
    items
  end
  
  ## Validation
  def valid_filename?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_]+$/
      errors.add name, :not_a_filename
    elsif value =~ /^[\.]+$/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_path?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_\/]+$/
      errors.add name, :not_a_filename
    elsif value =~ /(^|\/)\.+(\/|$)/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_exist?(path, type = nil)
    return true unless ::File.exist?(path)
    if type == nil
      errors.add_to_base "ファイルが既に存在します。"
    elsif type == :file
      errors.add_to_base "ファイルが既に存在します。" if ::File.file?(path)
    elsif type == :directory
      errors.add_to_base "ディレクトリが既に存在します。" if ::File.file?(path)
    end
    return errors.size == 0
  end
  
  def create_directory(name)
    @new_directory = name.to_s
    return false unless valid_filename?(:new_directory, @new_directory)
    
    src = ::File::join(upload_path, @new_directory)
    return false unless valid_exist?(src)
    
    FileUtils.mkdir(src)
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def create_file(name)
    @new_file = name.to_s
    return false unless valid_filename?(:new_file, @new_file)
    
    src = ::File::join(upload_path, @new_file)
    return false unless valid_exist?(src)
    
    FileUtils.touch(src)
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def upload_file(file)
    unless file
      errors.add :new_upload, :empty
      return false
    end
    
    src = ::File::join(upload_path, file.original_filename)
    if ::File.exist?(src) && FileTest.directory?(src)
      errors.add_to_base "同名のディレクトリが既に存在します。"
      return false
    end
    
    ::File.open(src,'w') do |f|
      data = file.read
      data.force_encoding(Encoding::UTF_8) if data.respond_to?(:force_encoding)
      f.write(data)
    end
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def update_file
    ::File.open(upload_path, 'w') do |f|
      data = self.body
      data.force_encoding(Encoding::UTF_8) if data.respond_to?(:force_encoding)
      f.write(data)
    end
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def rename(name)
    @new_name = name.to_s
    return false unless valid_filename?(:name, @new_name)
    
    src = upload_path
    dst = ::File::join(::File.dirname(upload_path), @new_name)
    
    is_dir = directory?
    FileUtils.mv(src, dst) if src != dst
    
    self.path = ::File.join(::File.dirname(path), @new_name)
    return false if is_dir && !save
    
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def move(new_path)
    @new_path = new_path.to_s.gsub(/\/+/, '/')
    
    return false unless valid_path?(:path, @new_path)
    
    src = upload_path
    dst = ::File::join(base_path, @new_path)
    return true if src == dst
    
    if !::File.exist?(::File.dirname(dst))
      errors.add_to_base "ディレクトリが見つかりません。（ #{::File.dirname(dst)} ）"
    elsif src == ::File.dirname(dst)
      errors.add_to_base "ディレクトリが見つかりません。（ #{src} ）"
    end
    return false if errors.size != 0
    return false unless valid_exist?(dst, :file)
    
    is_dir = directory?
    FileUtils.mv(src, dst)
    
    self.path = @new_path
    return false if is_dir && !save
    
    return true
  rescue => e
    if e.to_s =~ /^same file/i
      return true
    elsif e.to_s =~ /^Not a directory/i
      errors.add_to_base "ディレクトリが見つかりません。（ #{dst} ）"
    else
      errors.add_to_base(e.to_s)
    end
    return false
  end
  
  def remove_file
    FileUtils.rm_rf(upload_path)
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  # def escaped_path
    # URI.escape(path)
  # end
end