require 'test_helper'

class NNetworksControllerTest < ActionController::TestCase
  setup do
    @n_network = n_networks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:n_networks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create n_network" do
    assert_difference('NNetwork.count') do
      post :create, n_network: { name: @n_network.name }
    end

    assert_redirected_to n_network_path(assigns(:n_network))
  end

  test "should show n_network" do
    get :show, id: @n_network
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @n_network
    assert_response :success
  end

  test "should update n_network" do
    patch :update, id: @n_network, n_network: { name: @n_network.name }
    assert_redirected_to n_network_path(assigns(:n_network))
  end

  test "should destroy n_network" do
    assert_difference('NNetwork.count', -1) do
      delete :destroy, id: @n_network
    end

    assert_redirected_to n_networks_path
  end
end
