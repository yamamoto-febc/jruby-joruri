# encoding: utf-8
module Sys::FormHelper
  def creator_form(form)
    item = @template.instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'sys/admin/_partial/creators/form', :locals => locals
  end
  
  def creator_view(item)
    locals = {:item => item}
    render :partial => 'sys/admin/_partial/creators/view', :locals => locals
  end
  
  def recognizer_form(form)
    item = @template.instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'sys/admin/_partial/recognizers/form', :locals => locals
  end
  
  def recognizer_view(item)
    locals = {:item => item}
    render :partial => 'sys/admin/_partial/recognizers/view', :locals => locals
  end
  
  def job_form(form)
    item = @template.instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'sys/admin/_partial/jobs/form', :locals => locals
  end
  
  def job_view(item)
    locals = {:item => item}
    render :partial => 'sys/admin/_partial/jobs/view', :locals => locals
  end
  
  def editable_group_form(form)
    item = @template.instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}
    render :partial => 'sys/admin/_partial/editable_groups/form', :locals => locals
  end
  
  def editable_group_view(item)
    locals = {:item => item}
    render :partial => 'sys/admin/_partial/editable_groups/view', :locals => locals
  end
end