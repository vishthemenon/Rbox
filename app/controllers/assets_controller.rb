class AssetsController < ApplicationController
  require 'open-uri'
  before_filter :authenticate_user!

  def index
    @assets = current_user.assets
  end

  def show
    @asset = current_user.assets.find(params[:id])
  end

  def new
    @asset = current_user.assets.build      
      if params[:folder_id]
       @current_folder = current_user.folders.find(params[:folder_id])  
       @asset.folder_id = @current_folder.id  
      end      
  end

  def create
   @asset = current_user.assets.build(params[:asset])  
  if @asset.save  
   flash[:notice] = "Successfully uploaded the file."  
  
   if @asset.folder
     redirect_to browse_path(@asset.folder)   
   else  
     redirect_to root_url  
   end        
  else  
   render :action => 'new'  
  end  
  end

  def edit
    @asset = current_user.assets.find(params[:id])
  end

  def update
    @asset = current_user.assets.find(params[:id])
    if @asset.update_attributes(params[:asset])
      redirect_to @asset, :notice  => "Successfully updated asset."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @asset = current_user.assets.find(params[:id])
    @asset.destroy
    redirect_to assets_url, :notice => "Successfully destroyed asset."
  end

  def get
    asset = current_user.assets.find_by_id(params[:id])
    if asset 
      # redirect_to asset.uploaded_file.url, :type => asset.uploaded_file_content_type
      tempdata = open(URI.parse(URI.encode(asset.uploaded_file.url)))
      send_data tempdata, filename: asset.uploaded_file_file_name
      #public link no restriction
      #redirect_to asset.uploaded_file.url, :type => asset.uploaded_file_content_type 
    else
      flash[:error] = "Hello boss, if not yours den why you want!"
      redirect_to assets_path
    end
  end


end