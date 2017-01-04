class NNetworksController < ApplicationController
  before_action :set_n_network, only: [:show, :edit, :update, :destroy, :compare]

  def compare
    @picture = Picture.last
    pn = NeuralNetwork.new(ChunkyPNG::Image.from_file(@picture.image.path(:thumb)), File.basename(@picture.image.path(:thumb), ".*"), 1, 1)
    pn.weights_1 = eval(@n_network.weights)
    pn.weights_1_matrix = Matrix.columns(pn.weights_1)
    pn.create_hidden_layer
    pn.hidden = pn.hidden.to_a.flatten

    others = []
    @result = {}
    Picture.all.each do |picture|
      if picture != @picture
        n = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"), 1, 1)
        n.weights_1 = eval(@n_network.weights)
        n.weights_1_matrix = Matrix.columns(n.weights_1)
        n.create_hidden_layer
        n.hidden = n.hidden.to_a.flatten

        errors = []
        pn.hidden.each_with_index do |ph, pi|
          errors << (ph - n.hidden[pi]) / n.hidden[pi] # Chyba vzhladom na vybrany obr.
        end
        pre = (errors.sum.abs / errors.size) # Priemerna relativna chyba
        if 0.0 <= pre && pre <= 1.0
          pre = 1 - pre
        else
          pre = 0
        end
        @result[picture] = pre
      end
    end
    @result = @result.sort_by { |k, v| v }.reverse
  end

  # GET /n_networks
  # GET /n_networks.json
  def index
    @n_networks = NNetwork.all
  end

  # GET /n_networks/1
  # GET /n_networks/1.json
  def show
  end

  # GET /n_networks/new
  def new
    @n_network = NNetwork.new
  end

  # GET /n_networks/1/edit
  def edit
  end

  # POST /n_networks
  # POST /n_networks.json
  def create
    @n_network = NNetwork.new(n_network_params)

    respond_to do |format|
      if @n_network.save
        format.html { redirect_to @n_network, notice: 'N network was successfully created.' }
        format.json { render :show, status: :created, location: @n_network }
      else
        format.html { render :new }
        format.json { render json: @n_network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /n_networks/1
  # PATCH/PUT /n_networks/1.json
  def update
    respond_to do |format|
      if @n_network.update(n_network_params)
        format.html { redirect_to @n_network, notice: 'N network was successfully updated.' }
        format.json { render :show, status: :ok, location: @n_network }
      else
        format.html { render :edit }
        format.json { render json: @n_network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /n_networks/1
  # DELETE /n_networks/1.json
  def destroy
    @n_network.destroy
    respond_to do |format|
      format.html { redirect_to n_networks_url, notice: 'N network was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_n_network
    @n_network = NNetwork.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def n_network_params
    params.require(:n_network).permit(:name, :learning_rate, :repeat_cnt)
  end
end
