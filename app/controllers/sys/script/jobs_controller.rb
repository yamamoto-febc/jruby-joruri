class Sys::Script::JobsController < ApplicationController
  def exec
    job = Sys::Job.new
    job.and :process_at, '<=', Time.now + (60 * 5) # before 5 min
    jobs = job.find(:all, :order => :process_at)
    
    if jobs.size == 0
      return render(:text => "No Jobs")
    end
    
    jobs.each do |job|
      begin
        unless unid = job.unid_data
          job.destroy
          raise 'Unid Not Found'
        end
        
        model = unid.model.underscore.pluralize
        item  = eval(unid.model).find_by_unid(unid.id)
        
        model = "cms/nodes" if model == "cms/model/node/pages" # for v1.1.7
        
        job_ctr = model.gsub(/^(.*?)\//, '\1/script/')
        job_act = "#{job.name}_by_job"
        job_prm = {:unid => unid, :job => job, :item => item}
        render_component_as_string :controller => job_ctr, :action => job_act, :params => job_prm
        
        Script.keep_lock
      rescue => e
        puts "Error: #{e}"
      end
    end
    
    render(:text => "OK")
  end
end
