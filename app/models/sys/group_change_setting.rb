# encoding: utf-8
class Sys::GroupChangeSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  attr_accessor :form_type, :options

  validates_presence_of :name

  def self.categories
    [{:id => :sys_user_group,  :name => 'ユーザ/グループ',
                               :temp_models => ['Sys::GroupChangeGroup', 'Sys::GroupChange::Creator', 'Sys::GroupChange::EditableGroup'],
                               :options => [] },
     {:id => :cms_data_text,   :name => 'データ/テキスト',
                               :temp_models => ['Cms::GroupChange::DataText'],
                               :options => [['テキスト名','title'], ['本文','body']] },
     {:id => :cms_data_file,   :name => 'データ/ファイル',
                               :temp_models => ['Cms::GroupChange::DataFile'],
                               :options => [['表示ファイル名','title']] },
     {:id => :cms_piece,       :name => 'デザイン/ピース',
                               :temp_models => ['Cms::GroupChange::Piece'],
                               :options => [['ピース名','title'], ['表示タイトル','view_title'], ['本文','body']] },
     {:id => :cms_piecelink,   :name => 'デザイン/ピース(リンク集)',
                               :temp_models => ['Cms::GroupChange::PieceLinkItem'],
                               :options => [['リンク名','name'], ['URL','uri']] },
     {:id => :cms_layout,      :name => 'デザイン/レイアウト',
                               :temp_models => ['Cms::GroupChange::Layout'],
                               :options => [['レイアウト名','title'], ['標準レイアウト','body'], ['携帯レイアウト','mobile_body'], ['スマートフォンレイアウト','smart_phone_body']] },
     {:id => :cms_node,        :name => 'ディレクトリ/ディレクトリ・ページ',
                               :temp_models => ['Cms::GroupChange::Node'],
                               :options => [['タイトル','title'],['本文','body'],['携帯タイトル','mobile_title'], ['携帯本文','mobile_body']] },
     {:id => :article_doc,     :name => 'コンテンツ/記事',
                               :temp_models => ['Article::GroupChange::Doc'],
                               :options => [['タイトル','title'],['本文','body'],['携帯タイトル','mobile_title'], ['携帯本文','mobile_body']] },
     {:id => :calendar_event,  :name => 'コンテンツ/カレンダー',
                               :temp_models => ['Calendar::GroupChange::Event'],
                               :options => [['イベント名','title']] },
     {:id => :faq_doc,         :name => 'コンテンツ/FAQ',
                               :temp_models => ['Faq::GroupChange::Doc'],
                               :options => [['タイトル','title'],['質問','question'],['回答','body'],['携帯タイトル','mobile_title'], ['携帯本文','mobile_body']] },
     {:id => :cms_map,         :name => '共通/地図',
                               :temp_models => ['Article::GroupChange::Map'],
                               :options => [['マップ名称','title']] },
     {:id => :cms_map_marker,  :name => '共通/地図(マーカー)',
                               :temp_models => ['Article::GroupChange::MapMarker'],
                               :options => [['マーカー名称','name']] },
     {:id => :cms_inquiry,     :name => '共通/連絡先',
                               :temp_base   => 'Cms::GroupChange::Inquiry',
                               :temp_models => ['Cms::GroupChange::NodeInquiry', 'Article::GroupChange::Inquiry', 'Faq::GroupChange::Inquiry'],
                               :options => [['メールアドレス','email']] },
# unused
#     {:id => :node_inquiry,    :name => 'ディレクトリ/ディレクトリ(連絡先)',
#                               :temp_models => ['Cms::GroupChange::NodeInquiry'],
#                               :options => [['メールアドレス','email']] },
#     {:id => :article_tag,     :name => 'コンテンツ/記事(関連ワード)',
#                               :temp_models => ['Article::GroupChange::Tag'],
#                               :options => [['本文','word']] },
#     {:id => :article_map,     :name => 'コンテンツ/記事(地図)',
#                               :temp_models => ['Article::GroupChange::Map'],
#                               :options => [['マップ名称','title'],['マーカー名称','point_name']] },
#     {:id => :article_inquiry, :name => 'コンテンツ/記事(連絡先)',
#                               :temp_models => ['Article::GroupChange::Inquiry'],
#                               :options => [['メールアドレス','email']] },
    ]
  end

  def self.set_config(id, params = {})
    @@configs ||= {}
    @@configs[self] ||= []
    @@configs[self] << params.merge(:id => id)
  end

  def self.set_configs
    self.categories.each do |cate|
      next if cate[:id] == :sys_user_group
      self.set_config cate[:id], :name => cate[:name], :form_type => 'check_box', :options => cate[:options]
    end
  end

  #initialize
  self.set_configs


  def self.cate_temp_class_name(key)
    # self.categories.each {|cate| return cate[:temp_models][0] if cate[:id].to_s == key }
    self.categories.each do|cate|
      if cate[:id].to_s == key
        return cate[:temp_base] if cate[:temp_base]
        return cate[:temp_models][0]
      end
    end
  end

  def self.configs
    configs = []
    @@configs[self].each {|c| configs << config(c[:id])}
    configs
  end

  def self.config(name)
    cond = {:name => name.to_s }
    self.find(:first, :conditions => cond) || self.new(cond)
  end

  def config
    return @config if @config
    @@configs[self.class].each {|c| return @config = c if c[:id].to_s == name.to_s}
    nil
  end

  def config_name
    config ? config[:name] : nil
  end

  def form_type
    config ? config[:form_type] : nil
  end

  def config_options
    config ? config[:options] : nil
  end

  def value_to_hash
    return nil if value == nil
    h = {}
    value.to_s.split(/ /).each {|v| h[v] = v }
    h
  end

  def value_name
    if config[:options]
      return nil if value == nil
      vs = value.to_s.split(/ /)
      n = []
      config[:options].each {|c|
        vs.each {|v| n << c[0] if c[1].to_s == v }
      }
      return n.join(', ')
    else
      return value if !value.blank?
    end
    nil
  end

  def default_value_name
    if config[:options]
      n = []
      config[:options].each {|c| n << c[0] }
      return n.join(', ')
    else
      return ''
    end
  end
end
