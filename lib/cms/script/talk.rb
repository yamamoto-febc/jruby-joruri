class Cms::Script::Talk
  def self.make
    options = {:agent => "#{self}.add_paths"}
    @@log1 = Sys::Lib::Logger::Date.new(:cms_add_talk_paths, options)
    
    unless @@lock = lock_process
      @@log1.close("Already executing.")
      return false 
    end
    
    add_paths
    @@lock.updated_at = Time.now.to_s(:db)
    @@lock.save
    
    options = {:agent => "#{self}.make_sound_files"}
    @@log2 = Sys::Lib::Logger::Date.new(:cms_make_sound_files, options)
    
    make_sound_files
    @@lock.destroy
  end
  
protected
  def self.lock_process
    lock_key = '#making'
    if lock = Cms::TalkJob.find_by_path(lock_key)
      if lock.updated_at.strftime('%s').to_i + (60 * 10) < Time.now.strftime('%s').to_i
        lock.destroy
      else
        return nil
      end
    end
    lock = Cms::TalkJob.new(:site_id => 0, :path => lock_key, :uri => lock_key)
    return nil unless lock.save
    return lock
  end
  
  ## add sound paths.
  def self.add_paths
    root = Cms::Node.find(1)
    @@added = 0
    add_paths_by_node(root)
    
    @@log1.close("Finished. Added: #{@@added}")
  end
  
  def self.add_paths_by_node(node)
    if node.parent_id == 0 || (node.content_id != nil && node.controller != 'nodes')
      require 'site'
      Core.set_site(node.site)
      
      params = {
        :site_id    => node.site_id,
        :content_id => node.content_id,
        :controller => node.controller,
        :path       => node.public_path,
        :uri        => node.public_uri,
        :regular    => 1
      }
      if Cms::TalkJob.add(params)
          @@log1.puts("add: #{params[:site_id]}, #{params[:uri]}, #{params[:path]}")
          @@added += 1
      end
    end
    
    node.children.each do |child|
      add_paths_by_node(child) if child.public?
    end
  end
  
  ## make sound files.
  def self.make_sound_files
    success = 0
    error   = 0
    
    ## find jobs
    cond = ['site_id != 0']
    jobs = Cms::TalkJob.find(:all, :conditions => cond, :order => 'regular DESC, id')
    if jobs.size == 0
      @@log2.close("Finished. No jobs.")
      return true
    end
    
    require 'site'
    
    ## make
    count = 0
    jobs.each_with_index do |job, idx|
      begin
        count += 1
        if count % 50 == 0
          GC.start
        end
        
        @@log2.puts("make: #{job.id}, #{job.site_id}, #{job.uri}")
        #@@log2.puts("make: #{job.id}, #{job.site_id}, #{job.uri}, #{job.sound_path}")
        #@@log2.puts("make: #{job.id}, #{job.site_id}, #{job.content_uri}, #{job.sound_path}")
        
        unless content = job.read_content
          raise 'ReadContentError'
        end
        
        if job.regular == 1 && job.content == content && FileTest.exist?(job.sound_path)
          @@log2.puts(" => No changed.")
          next
        end
        file = job.make_sound(content)
        if !file || File::stat(file[:path]).size == 0
          raise 'MakeSoundError'
        end
        
        dir = ::File.dirname(job.sound_path)
        FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
        FileUtils.mv(file[:path], job.sound_path)
        ::File.chmod(0644, job.sound_path)
        job.content = content
        job.result  = 'success'
        job.terminate
        
        success += 1
        @@log2.puts(" => Success.")
        
      #rescue NotImplementedError
      #  success += 1
      rescue => e
        @@log2.puts(" => #{e}")
        if job.result == 'error'
          FileUtils.rm(job.sound_path) if FileTest.exist?(job.sound_path)
          job.destroy
        else
          job.result = 'error'
          job.terminate
        end
        error += 1
      end
      
      @@lock.updated_at = Time.now.to_s(:db)
      @@lock.save
    end
    
    if error > 0
      @@log2.close("Finished. Made: #{success}, Error: #{error}")
    else
      @@log2.close("Finished. Made: #{success}")
    end
  end
end
