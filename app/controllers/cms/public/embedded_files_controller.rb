# encoding: utf-8
class Cms::Public::EmbeddedFilesController < ApplicationController
  def down
    return http_error(404) if params[:path].size < 2 || params[:path].size > 3
    return http_error(404) if params[:path][0] !~ /^[0-9]+$/
    
    filename = params[:path][1]
    if params[:path].size == 3
      return http_error(404) if params[:path][1] != "thumb"
      type     = params[:path][1]
      filename = params[:path][2]
    end
    
    item = Cms::EmbeddedFile.new.public
    item.and :id, params[:path][0].gsub(/.$/, '')
    item.and :site_id, Page.site.id 
    item.and :name, filename
    return http_error(404) unless item = item.find(:first, :order => :id)
    
    path = item.public_path
    if params[:path].size == 3 && params[:path][1] == "thumb"
      path = path.to_s.gsub(/^(.*)\//, '\\1/thumb/')
      item.image_width  = item.thumb_width
      item.image_height = item.thumb_height
    end
    return http_error(404) unless FileTest.exist?(path)
    
    if img = item.mobile_image(request.mobile, :path => path)
      return send_data(img.to_blob, :type => item.mime_type, :filename => item.name, :disposition => 'inline')
    end
    return send_file(path, :type => item.mime_type, :filename => item.name, :disposition => 'inline')
  end
end