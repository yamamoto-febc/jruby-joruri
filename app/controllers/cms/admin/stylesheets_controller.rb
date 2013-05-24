# encoding: utf-8
class Cms::Admin::StylesheetsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @path      = params[:path].join('/').to_s.force_encoding('utf-8')
    @item = Cms::Stylesheet.new_by_path(@path)
    
    unless ::File.exist?(@item.upload_path)
      return http_error(404) if flash[:notice]
      flash[:notice] = "指定されたパスは存在しません。（ #{@item.upload_path} ）"
      redirect_to(cms_stylesheets_path(''))
    end
  end
  
  def index
    return show    if params[:do] == 'show'
    return new     if params[:do] == 'new'
    return edit    if params[:do] == 'edit'
    return update  if params[:do] == 'update'
    return rename  if params[:do] == 'rename'
    return move    if params[:do] == 'move'
    return destroy if params[:do] == 'destroy'
    if params[:do].nil? && !@item.directory?
      params[:do] = "show"
      return show
    end
    if request.post? && location = create
      return redirect_to(location)
    end
    
    @dirs  = @item.child_directories
    @files = @item.child_files
  end
  
  def show
    #return error_auth unless @item.readable?
    
    @item.read_body
    render :action => :show
  end
  
  def new
    return error_auth unless @item.creatable?
    
    render :action => :new
  end
  
  def edit
    return error_auth unless @item.editable?
    
    @item.read_body
    render :action => :edit
  end
  
  def create
    return error_auth unless @item.creatable?
      
    if params[:create_directory]
      if @item.create_directory(params[:item][:new_directory])
        flash[:notice] = 'ディレクトリを作成しました。'
        return cms_stylesheets_path(@path)
      end
    elsif params[:create_file]
      if @item.create_file(params[:item][:new_file])
        flash[:notice] = 'ファイルを作成しました。'
        return cms_stylesheets_path(::File.join(@path, params[:item][:new_file]), :do => 'edit')
      end
    elsif params[:upload_file]
      if @item.upload_file(params[:item][:new_upload])
        flash[:notice] = 'アップロードが完了しました。'
        return cms_stylesheets_path(@path)
      end
    end
    return false
  end
  
  def rename
    return error_auth unless @item.editable?
    
    if request.put?
      @item.concept_id = params[:item][:concept_id]
      @item.site_id    = Core.site.id if @item.concept_id 
      
      if @item.rename(params[:item][:name])
        flash[:notice] = '更新処理が完了しました。'
        location = cms_stylesheets_path(::File.dirname(@path))
        return redirect_to(location)
      end
    end
    render :action => :rename
  end
  
  def move
    return error_auth unless @item.editable?
    
    if request.put?
      if @item.move(params[:item][:path])
        flash[:notice] = '更新処理が完了しました。'
        location = cms_stylesheets_path(::File.dirname(@path))
        return redirect_to(location)
      end
    end
    render :action => :move
  end
  
  def update
    return error_auth unless @item.editable?
    
    @item.body = params[:item][:body]
    
    if @item.valid? && @item.update_file
      flash[:notice] = '更新処理が完了しました。'
      location = cms_stylesheets_path(@path, :do => 'edit')
      return redirect_to(location)
    end
    render :action => :edit
  end
  
  def destroy
    return error_auth unless @item.deletable?
    
    if @item.destroy
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。（#{@item.errors.full_messages.join(' ')}）"
    end
    location = cms_stylesheets_path(::File.dirname(@path))
    return redirect_to(location)
  end
end
