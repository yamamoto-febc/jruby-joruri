require 'jpmobile'

module Jpmobile
  module RequestWithMobile
    def smart_phone?
      return true if user_agent =~ /Android/
      return true if user_agent =~ /iPhone/
      return true if user_agent =~ /Windows Phone/
      return true if user_agent =~ /MSIEMobile/
      false
    end
  end
end
