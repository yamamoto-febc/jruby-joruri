# encoding: utf-8
module Sys::GroupChangeHelper

  def temporary_view(action, model_name)
    arr = model_name.split(/::/)
    mod = arr.slice!(0,1)[0].downcase
    arr.slice!(0,1) if arr.size > 1
    dr = []
    arr.each {|s| dr << s.underscore.downcase }
    render :partial => "#{mod}/admin/_partial/group_change_temporaries/#{dr.join('_')}/#{action}"
  end

  def execute_logs_view
    render :partial => 'sys/admin/_partial/group_changes/logs/index'
  end

end