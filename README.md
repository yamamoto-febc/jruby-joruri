#change for jruby

* ruby-ldap : jruby-ldap
* rmagick   : rmagick4j
* zipruby   : nothing!! :: need port for jruby
* mysql     : jdbc-mysql

##commentout
config/locales/active_support_ja.yml#18
config/environment.rb
    #require passive_record
base.rb #fetch_row 
initializer/fix_ruby1.91_rails2.3.16.rb # mysql