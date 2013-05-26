# jruby_joruri
[joruri](http://joruri.org)のjruby対応版


## jrubyでの実行方法(rvmでの例)
    #clone source
    git clone git@github.com:yamamoto-febc/jruby-joruri.git
	git checkout -b bundler origin/bundler

	#copy database.config
	cp config/database.config.sample config/database.config

	#change database.config
	vim config/database.config
	
	#install jruby
    rvm install jruby-1.7.3
    rvm use --create jruby-1.7.3@joruri

    # setup gems    
    gem install bundler
    bundle install

    # run
    bundle exec script/server -e production
    
        
##今後の予定
* ChaSen依存の除去:形態素解析部分の切り替え可能に
* GalateaTalk依存の除去:同上
* rails3対応:本家が対応するまで待ちたい。



## jruby対応での変更点

####gemの変更
* ruby-ldap : jruby-ldapへ  
* rmagick   : rmagick4jへ
* zipruby   : 対応するgemなし。fastercsvで利用しているため、今後のrails3対応の中で依存をなくしていく
* mysql     : jdbc-mysqlへ変更
* passiverecord : unpackしてdependencyを修正

#### ソースの変更点
    config/locales/active_support_ja.yml # 行18 TODO要修正
    base.rb #fetch_row 除去
    initializer/fix_ruby1.91_rails2.3.16.rb # mysql関連削除
    'Task'を'Job'へ変更(クラス名やファイル名などに存在)


