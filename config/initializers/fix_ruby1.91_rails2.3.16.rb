# encoding: utf-8
# patch for ruby1.9.1 and Rails2.3.15

Encoding.default_internal = 'utf-8'
Encoding.default_external = 'utf-8'

class Symbol; def to_a; [self.to_s]; end; end

class ::String #:nodoc:
  def to_a
    [self.to_s]
  end
  
  def blank?
    (!self.respond_to?(:valid_encoding?) or self.valid_encoding?) ? self !~ /\S/ : self.strip.size == 0
  end
end

require 'mysql'
class Mysql::Result
  def encode(value, encoding = "utf-8")
    String === value ? value.force_encoding(encoding) : value
  end
  
  def each_utf8(&block)
    each_orig do |row|
      yield row.map {|col| encode(col) }
    end
  end
  alias each_orig each
  alias each each_utf8
 
  def each_hash_utf8(&block)
    each_hash_orig do |row|
      row.each {|k, v| row[k] = encode(v) }
      yield(row)
    end
  end
  alias each_hash_orig each_hash
  alias each_hash each_hash_utf8
end

module ActionController
  class Request
    private
      # Convert nested Hashs to HashWithIndifferentAccess and replace
      # file upload hashs with UploadedFile objects
      def normalize_parameters(value)
        case value
        when Hash
          if value.has_key?(:tempfile)
            upload = value[:tempfile]
            upload.extend(UploadedFile)
            upload.original_path = value[:filename]
            upload.content_type = value[:type]
            upload
          else
            h = {}
            value.each { |k, v| h[k] = normalize_parameters(v) }
            h.with_indifferent_access
          end
        when Array
          value.map { |e| normalize_parameters(e) }
        else
          value.force_encoding(Encoding::UTF_8) if value.respond_to?(:force_encoding)
          value
        end
      end
  end
end

class ERB
  module Util
    def html_escape(s)
      s = s.to_s
      
      ## check encoding
      s.force_encoding(Encoding::UTF_8) if s.respond_to?(:force_encoding)
      
      if s.html_safe?
        s
      else
        s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;").html_safe
      end
    end
    
    alias h html_escape
    module_function :html_escape
  end
end
