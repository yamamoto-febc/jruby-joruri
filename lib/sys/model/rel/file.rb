# encoding: utf-8
module Sys::Model::Rel::File
  def self.included(mod)
    mod.has_many :files, :foreign_key => 'parent_unid', :class_name => 'Sys::File',
      :primary_key => 'unid', :dependent => :destroy
    
    # mod.before_save :publish_files
      # :if => %Q(@save_mode == :publish)
    # mod.before_save :close_files,
      # :if => %Q(@save_mode == :close)
    mod.after_destroy :close_files
  end
  
  ## Remove the temporary flag.
  def fix_tmp_files(tmp_id)
    Sys::File.fix_tmp_files(tmp_id, unid)
    return true
  end
  
  def public_files_path
    "#{::File.dirname(public_path)}/files"
  end
  
  def publish_files
    #return true unless @save_mode == :publish
    return true if files.size == 0
    
    public_dir = public_files_path
    
    files.each do |file|
      upload_path = file.upload_path
      upload_dir  = ::File.dirname(upload_path)
      
      paths = {
        upload_path => "#{public_dir}/#{file.name}",
        "#{upload_dir}/thumb.dat" => "#{public_dir}/thumb/#{file.name}"
      }
      
      paths.each do |fr, to|
        next unless FileTest.exist?(fr)
        next if FileTest.exist?(to) && ( File::stat(to).mtime >= File::stat(fr).mtime)
        FileUtils.mkdir_p(::File.dirname(to)) unless FileTest.exist?(::File.dirname(to))
        FileUtils.cp(fr, to)
      end
    end
    
    return true
  end
  
  def close_files
    #return true unless @save_mode == :close
    
    dir = public_files_path
    FileUtils.rm_r(dir) if FileTest.exist?(dir)
    return true
  end
end