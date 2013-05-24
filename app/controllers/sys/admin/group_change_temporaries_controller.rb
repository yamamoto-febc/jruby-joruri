# encoding: utf-8
class Sys::Admin::GroupChangeTemporariesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Sys::GroupChangeHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @parent = params[:parent]
    return error_auth if @parent != '0'
    @data_cls = Sys::GroupChangeSetting.cate_temp_class_name(params[:current])

    @log = Sys::GroupChangeLog.find_by_id(1) || Sys::GroupChangeLog.new
  end

  def index
    @settings      = _settings_index
    item = eval(@data_cls).new
    item.add_condition
    item.order_by
    item.page  params[:page], params[:limit]
    @items = item.find(:all)
    _index @items
  end

  def show
  end

  def new
    _test_groups
    send(params[:do]) if params[:do]
  end

  def confirm
    # check
    last_update_changes  = Sys::GroupChange.maximum(:updated_at)
    last_update_settings = Sys::GroupChangeSetting.maximum(:updated_at)

    @messages[:common] << '<span class="notice">※組織設定が登録されていません</span>'   if last_update_changes == nil
    @messages[:common] << '<span class="notice">※中間データが作成されていません</span>' if @log.updated_at == nil
    if last_update_changes && @log.updated_at && last_update_changes.strftime('%Y-%m-%d %H:%M:%S') > @log.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      @messages[:common] << '<span class="notice">※中間データ作成後に、組織設定が変更されています</span>'
    end
    if last_update_settings && @log.updated_at && last_update_settings.strftime('%Y-%m-%d %H:%M:%S') > @log.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      @messages[:common] << '<span class="notice">※中間データ作成後に、置換設定が変更されています</span>'
    end

    render :action => :confirm
  end

  def create
    settings = _settings_index
    _truncate_temptable settings
    changes = _changes_index

    _create_temporary changes, settings

    flash[:notice] = '中間データ作成処理が完了しました。'
    redirect_to :action => :index
  end

  def synchronize
    settings = _settings_index
    changes = _changes_index
    _synchronize_data changes, settings

    flash[:notice] = '組織変更処理が完了しました。'
    redirect_to :action => :index
  end

  def update
    return error_auth
  end

  def destroy
    return error_auth
  end

private
  def _truncate_temptable(settings)
#      settings.each do |setting|
#        setting[:temp_models].each {|temp| eval("#{temp}").new.truncate_table }
#      end
    Sys::GroupChangeGroup.new.truncate_table
    Sys::GroupChangeItem.new.truncate_table
  end

  def _settings_index
    return Sys::GroupChangeSetting.categories
  end

  def _changes_index
    item = Sys::GroupChange.new
    item.default_order
    return item.find(:all)
  end

  def _create_temporary(changes, settings)
     @log.update_exec_state('preparing', :body =>
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- 中間データ作成処理が開始されました。")

    # pick up targets
    changes.each {|change| Sys::GroupChangeGroup.new.pull change, nil }

    changes.each do |change|
      next unless change.temp_group
      @log.update_exec_state('preparing', :body =>
        "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- #{change.code} #{change.name} 開始", :body_add_type => 'append')
      settings.each do |setting|
        setting[:temp_models].each do |model|
          next if model == 'Sys::GroupChangeGroup'
          temp = eval("#{model}").new
          temp.pull change, setting
        end
      end
    end
    @log.update_exec_state('prepared', :body =>
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- 中間データ作成処理が完了しました。", :body_add_type => 'append')
  end



  def _synchronize_data(changes, settings)
    @log.update_exec_state('executing', :body =>
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- 組織反映処理が開始されました。")

    # narrow down
    changes.delete_if {|change| !change.temp_group }

    settings.each do |setting|
      @log.update_exec_state('executing', :body =>
        "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- #{setting[:name]} 開始", :body_add_type => 'append')
      setting[:temp_models].each do |model|
        temp = eval("#{model}").new
        temp.synchronize changes, setting
      end
    end
    @log.update_exec_state('completed', :body =>
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} -- 組織反映処理が処理が完了しました。", :body_add_type => 'append')
  end


  def _test_groups
    @messages = {:common => [], :new => [], :ren => [], :uni => [], :itg => [], :del => []}

    addmsg = Proc.new do |_k, _i, _e|
      _msg  = "（#{_i.code} #{_i.name}）"
      _msg += " ← （#{_i.old_code} #{_i.old_name}）" if _i.old_code.to_s != ''
      _msg += '<span class="notice">※' + _e.join(' ※') + '</span>' if _e.size > 0
      @messages[_k] << _msg
    end

    cond  = {:change_division => 'add'}
    order = "parent_code, code"
    Sys::GroupChange.find(:all, :conditions => cond, :order => order).each do |item|
      errors = []
      #errors << 'メールアドレスが入力されていません' if item.email.blank?
      errors << '対象が既に存在します' if Sys::Group.find_by_code(item.code)
      errors << '上位組織名が存在しません' unless Sys::Group.find_by_code(item.parent_code)
      addmsg.call(:new, item, errors)
    end

    cond  = {:change_division => 'move' }
    Sys::GroupChange.find(:all, :conditions => cond, :order => order).each do |item|
      errors = []
      #errors << 'メールアドレスが入力されていません' if item.email.blank?
      #errors << '対象が既に存在します' if Sys::Group.find_by_code(item.code)
      errors << '対象が既に存在します' if Sys::Group.find(:first, :conditions => {:code => item.code, :name => item.name})
      if item.old_code && !Sys::Group.find(:first, :conditions => {:code => item.old_code, :name => item.old_name})
        errors << '引継元が見つかりません'
      end
      addmsg.call(:uni, item, errors)
    end

    cond  = {:change_division => 'integrate' }
    Sys::GroupChange.find(:all, :conditions => cond, :order => order).each do |item|
      errors = []
      #errors << 'メールアドレスが入力されていません' if item.email.blank?
      #errors << '対象が既に存在します' if Sys::Group.find_by_name(item.name)
      if item.old_code && !Sys::Group.find(:first, :conditions => {:code => item.old_code, :name => item.old_name})
        errors << '引継元が見つかりません'
      end
      addmsg.call(:itg, item, errors)
    end

    cond  = {:change_division => 'dismantle' }
    Sys::GroupChange.find(:all, :conditions => cond, :order => order).each do |item|
      errors = []
      errors << '対象が見つかりません' unless Sys::Group.find_by_code(item.code)
      addmsg.call(:del, item, errors)
    end
  end

end
