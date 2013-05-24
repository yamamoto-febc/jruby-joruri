# encoding: utf-8
class Sys::Admin::GroupChangeSettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @items = Sys::GroupChangeSetting.configs
    _index @items
  end

  def show
    @item = Sys::GroupChangeSetting.config(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    value = ''
    if params[:item]
      v = params[:item][:value] || {}
      value = v.values.join(' ')
    end
    @item = Sys::GroupChangeSetting.config(params[:id])
    @item.value = value
    _update(@item)
  end

  def destroy
    error_auth
  end

end
