require 'mime/types'
class Sys::Lib::File::NoUploadedFile
  def initialize(path, options = {})
    if path.class == Hash
      options      = path
      @data        = options[:data]
      @mime_type   = options[:mime_type] if options[:mime_type]
      @mime_type ||= MIME::Types.type_for(options[:filename])[0].to_s if options[:filename]
    else
      file         = ::File.new(path)
      @data        = file.read
      @mime_type   = options[:mime_type] if options[:mime_type]
      @mime_type ||= MIME::Types.type_for(path)[0].to_s
    end
    @filename  = options[:filename]
    @size      = @data.size if @data
    @image     = validate_image
  end
  
  def errors
    @errors
  end
  
  def read
    @data
  end
  
  def original_filename
    @filename
  end
  
  def size
    @size
  end
  
  def mime_type
    @image ? @image.mime_type : @mime_type
  end
  
  def content_type
    mime_type
  end
  
  def image_is
    @image ? 1 : 2
  end
  
  def image_width
    @image ? @image.columns : nil
  end
  
  def image_height
    @image ? @image.rows : nil
  end
  
  def validate_image
    begin
      if @filename.to_s =~ /\.(bmp|gif|jpg|jpeg|png)$/i
        require 'RMagick'
        image = Magick::Image.from_blob(@data).shift
        return image if image.format =~ /(GIF|JPEG|PNG)/
      end
      return nil
    rescue LoadError
      return nil
    rescue Magick::ImageMagickError
      return nil
    rescue NoMethodError
      return nil
    rescue
      return nil
    end
  end
end