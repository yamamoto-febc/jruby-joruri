# encoding: utf-8
require 'digest/md5'
module Cms::Model::Base::Page::TalkJob
  def self.included(mod)
    mod.has_many :talk_jobs, :foreign_key => 'unid', :primary_key => 'unid', :class_name => 'Cms::TalkJob',
      :dependent => :destroy
    mod.after_save :delete_talk_jobs
  end
  
  def publish_page(content, options = {})
    return false unless super
    cond = options[:dependent] ? ['dependent = ?', options[:dependent].to_s] : ['dependent IS NULL']
    pub  = publishers.find(:first, :conditions => cond)
    return true unless pub
    return true if pub.path !~ /\.html$/
    #return true if !published? && ::File.exist?("#{pub.path}.mp3")
    
    path = "#{pub.path}.mp3"
    talk = nil
    if published?
      talk = true
    elsif !::File.exist?(path)
      talk = true
    elsif ::File.stat(path).mtime < Cms::KanaDictionary.dic_mtime(:talk)
      talk = true
    end
    
    if talk
      job = talk_jobs.find(:first, :conditions => cond) || Cms::TalkJob.new
      job.unid         = pub.unid
      job.dependent    = pub.dependent
      job.path         = pub.path
      job.content_hash = pub.content_hash
      job.save if job.changed?
    end
    return true
  end
  
  def delete_talk_jobs
    publishers.destroy_all
    return true
  end
end
