require 'test_helper'

class BatchTransfersControllerTest < ActionController::TestCase
  setup do
    @batch_transfer = batch_transfers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:batch_transfers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create batch_transfer" do
    assert_difference('BatchTransfer.count') do
      post :create, batch_transfer: @batch_transfer.attributes
    end

    assert_redirected_to batch_transfer_path(assigns(:batch_transfer))
  end

  test "should show batch_transfer" do
    get :show, id: @batch_transfer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @batch_transfer.to_param
    assert_response :success
  end

  test "should update batch_transfer" do
    put :update, id: @batch_transfer.to_param, batch_transfer: @batch_transfer.attributes
    assert_redirected_to batch_transfer_path(assigns(:batch_transfer))
  end

  test "should destroy batch_transfer" do
    assert_difference('BatchTransfer.count', -1) do
      delete :destroy, id: @batch_transfer.to_param
    end

    assert_redirected_to batch_transfers_path
  end
end
