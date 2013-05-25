# encoding: utf-8
require 'digest/md5'
class Cms::Script::TalkJobsController < Cms::Controller::Script::Publication
  def exec
    Cms::TalkJob.find(:all, :select => :id, :order => "id").each do |v|
      job = Cms::TalkJob.find_by_id(v[:id])
      next unless job
      begin
        if ::File.exist?(job.path)
          rs = make_sound(job)
        else
          rs = true
        end
        job.destroy
        raise "MakeSoundError" unless rs
      rescue Exception => e
        error_log "#{e} #{job.path}"
      end
      Script.keep_lock
    end
    render :text => "OK"
  end
  
  def make_sound(job)
    content = ::File.new(job.path).read
    #hash = Digest::MD5.new.update(content.to_s).to_s
    #return true if hash == job.content_hash && ::File.exist?("#{job.path}.mp3")
    
    gtalk = Cms::Lib::Navi::Gtalk.new
    gtalk.make(content)
    mp3 = gtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0
    FileUtils.mv(mp3[:path], "#{job.path}.mp3")
    ::File.chmod(0644, "#{job.path}.mp3")
    return true
  end
end
