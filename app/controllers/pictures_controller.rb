class PicturesController < ApplicationController
  before_action :login_validate, only: %i[new edit show]
  before_action :set_picture, only: %i[edit show update destroy]

  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all.order(updated_at: :desc)
   render layout: 'index.html.erb'
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
    @favorite = current_user.favorites.find_by(picture_id: @picture.id)
  end

  # GET /pictures/new
  def new
    if params[:back]
     @picture = Picture.new(picture_params)
     else
     @picture = Picture.new
    end
  end

  # GET /pictures/1/edit
  def edit
  
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)
    @picture.image.retrieve_from_cache! params[:cache][:image]
    @picture.user_id = current_user.id # 現在ログインしているuserのidをpictureのuser_idカラムに挿入する。
    #キャッシュから画像を復元する
    PicturetoMailer.pictureto_mail(@picture.user).deliver
    # 省略

    respond_to do |format|
      if @picture.save
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: 'Picture was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def confirm
    # @favorites_pictures= Picture.where(user_id: current_user.favorites)
    @favorites_pictures = current_user.favorite_pictures

  end

  def check
    #@picture = Picture.new(picture_params)
    @picture = current_user.pictures.build(picture_params)
    render :new if @picture.invalid?
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_picture
    @picture = Picture.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def picture_params
    params.require(:picture).permit(:title,:content,:image)
  end

  def login_validate
    #  if !logged_in?
    #     redirect_to new_session_path
    if session[:user_id]
      begin
        @user = User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end
    redirect_to new_session_path unless @user
  end
end
