# jruby_joruri
[joruri](http://joruri.org)のjruby対応版

### jruby対応での変更点

####gemの変更
* ruby-ldap : jruby-ldapへ  
* rmagick   : rmagick4jへ
* zipruby   : 対応するgemなし。fastercsvで利用しているため、今後のrails3対応の中で依存をなくしていく
* mysql     : jdbc-mysqlへ変更
* passiverecord : unpackしてdependencyを修正

#### ソースの変更
config/locales/active_support_ja.yml # 行18 TODO要修正
base.rb #fetch_row 
initializer/fix_ruby1.91_rails2.3.16.rb # mysql