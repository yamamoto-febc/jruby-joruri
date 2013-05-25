module Sys::Model::Rel::Job
  attr_accessor :in_tags
  
  def self.included(mod)
    mod.has_many :jobs, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'Sys::Job',
      :dependent => :destroy
      
    mod.after_save :save_jobs
  end
  
  attr_accessor :_jobs
  
  def find_job_by_name(name)
    return nil if jobs.size == 0
    jobs.each do |job|
      return job.process_at if job.name == name.to_s
    end
    return nil
  end
  
  def in_jobs
    unless val = read_attribute(:in_jobs)
      val = {}
      jobs.each {|job| val[job.name] = job.process_at.strftime('%Y-%m-%d %H:%M') if job.process_at }
      write_attribute(:in_jobs, val)
    end
    read_attribute(:in_jobs)
  end
  
  def in_jobs=(values)
    _values = {}
    if values.class == Hash || values.class == HashWithIndifferentAccess
      values.each {|key, val| _values[key] = val }
    end
    @jobs = _values
  end
  
  def save_jobs
    return false unless unid
    return true unless @jobs
    
    values = @jobs
    @jobs = nil
    
    values.each do |k, date|
      name = k.to_s
      
      if date == ''
        jobs.each do |job|
          job.destroy if job.name == name
        end
      else
        items = []
        jobs.each do |job|
          if job.name == name
            items << job
          end
        end
        
        if items.size > 1
          items.each {|job| job.destroy}
          items = []
        end
        
        if items.size == 0
          job = Sys::Job.new({:unid => unid, :name => name, :process_at => date})
          job.save
        else
          items[0].process_at = date
          items[0].save
        end
      end
    end
    
    jobs(true)
    return true
  end
end