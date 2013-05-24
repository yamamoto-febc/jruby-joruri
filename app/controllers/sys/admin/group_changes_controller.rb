# encoding: utf-8
class Sys::Admin::GroupChangesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    item = Sys::GroupChange.new
    item.default_order
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Sys::GroupChange.new.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Sys::GroupChange.new({
      :old_division => 'keep'
    })
  end

  def create
    @item = Sys::GroupChange.new(params[:item])
    _create @item
  end

  def update
    @item = Sys::GroupChange.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Sys::GroupChange.new.find(params[:id])
    _destroy @item
  end

end
