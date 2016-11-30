class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
    if params[:method] == 'euclidean'
      if params[:threshold].blank?
        @threshold = 0.5
      else
        @threshold = params[:threshold].to_f
      end
      @pictures = Picture.all.to_a
      @pictures.each do |picture|
        picture.m = @picture.match(picture, @threshold)
      end
      @pictures.sort! { |x, y| y.m[:perc] <=> x.m[:perc] }
    elsif params[:method] == 'sqft'
      if params[:threshold_sqft].blank?
        @threshold = 10
      else
        @threshold = params[:threshold_sqft].to_i
      end
      @pictures = Picture.all.to_a
      @pictures.each do |picture|
        picture.m = @picture.match_sqft(picture, @threshold)
      end
      @pictures.sort! { |x, y| y.m <=> x.m }
    end
  end

  def compare
    @first = Picture.find(params[:first_id])
    @second = Picture.find(params[:second_id])
    if params[:threshold].blank?
      threshold = 0.5
    else
      threshold = params[:threshold].to_f
    end
    @result_pic = @first.create_combining_picture(@second, threshold, params[:my_color], params[:other_color], params[:match_color])
    if !params[:commit].blank?
      redirect_to compare_pictures_path(first_id: params[:first_id], second_id: params[:second_id],
                                        threshold: params[:threshold], my_color: params[:my_color],
                                        other_color: params[:other_color], match_color: params[:match_color])
    end
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  def second
    if !params[:picture_id].blank?
      @picture = Picture.find(params[:picture_id])
    else
      @picture = Picture.last
    end
    if !params[:commit].blank?
      if params[:method] == 'euclidean'
        @threshold = params[:threshold]
        @threshold = 0.5 if @threshold.blank?
        redirect_to picture_path(@picture, method: params[:method], threshold: @threshold)
      elsif params[:method] == 'sqft'
        @threshold = params[:threshold_sqft].to_i
        @threshold = 10 if @threshold.blank?
        redirect_to picture_path(@picture, method: params[:method], threshold_sqft: @threshold)
      else
        @threshold = 0
        redirect_to picture_path(@picture, method: params[:method], threshold: @threshold)
      end
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)
    if @picture.save
      render json: { message: "success", id: @picture.id }, :status => 200
    else
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @picture.errors.full_messages.join(',') }, :status => 400
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_picture
    @picture = Picture.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def picture_params
    params.require(:picture).permit(:image)
  end

end
