#!/usr/local/bin/ruby

puts "== gem install rake"
puts `gem install rake --no-ri --no-rdoc -v 0.8.7`

puts "== gem install Rails"
puts `gem install rails --no-ri --no-rdoc --include-dependencies -v 2.3.16`

puts "== gem install Ruby/LDAP"
puts `gem install ruby-ldap --no-ri --no-rdoc -v 0.9.10`

puts "== gem install RMagick"
puts `gem install rmagick --no-ri --no-rdoc -v 2.12.2`

puts "== gem install Zip/Ruby"
puts `gem install zipruby --no-ri --no-rdoc -v 0.3.6`

puts "== gem install mime-types"
puts `gem install mime-types --no-ri --no-rdoc -v 1.16`

puts "== gem install will_paginate"
puts `gem install will_paginate --no-ri --no-rdoc -v 2.3.16`

puts "== gem install PassiveRecord"
puts `gem install passiverecord --no-ri --no-rdoc -v 0.2`

puts "== gem install TamTam"
puts `gem install tamtam --no-ri --no-rdoc -v 0.0.3`

puts "== gem install Mysql/Ruby"
puts `gem install mysql --no-ri --no-rdoc -v 2.8.1`
