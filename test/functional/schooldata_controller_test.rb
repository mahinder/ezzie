require 'test_helper'

class SchooldataControllerTest < ActionController::TestCase
  setup do
    @schooldatum = schooldata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:schooldata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create schooldatum" do
    assert_difference('Schooldatum.count') do
      post :create, schooldatum: @schooldatum.attributes
    end

    assert_redirected_to schooldatum_path(assigns(:schooldatum))
  end

  test "should show schooldatum" do
    get :show, id: @schooldatum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @schooldatum.to_param
    assert_response :success
  end

  test "should update schooldatum" do
    put :update, id: @schooldatum.to_param, schooldatum: @schooldatum.attributes
    assert_redirected_to schooldatum_path(assigns(:schooldatum))
  end

  test "should destroy schooldatum" do
    assert_difference('Schooldatum.count', -1) do
      delete :destroy, id: @schooldatum.to_param
    end

    assert_redirected_to schooldata_path
  end
end
