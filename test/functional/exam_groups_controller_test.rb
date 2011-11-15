require 'test_helper'

class ExamGroupsControllerTest < ActionController::TestCase
  setup do
    @exam_group = exam_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exam_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exam_group" do
    assert_difference('ExamGroup.count') do
      post :create, exam_group: @exam_group.attributes
    end

    assert_redirected_to exam_group_path(assigns(:exam_group))
  end

  test "should show exam_group" do
    get :show, id: @exam_group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exam_group.to_param
    assert_response :success
  end

  test "should update exam_group" do
    put :update, id: @exam_group.to_param, exam_group: @exam_group.attributes
    assert_redirected_to exam_group_path(assigns(:exam_group))
  end

  test "should destroy exam_group" do
    assert_difference('ExamGroup.count', -1) do
      delete :destroy, id: @exam_group.to_param
    end

    assert_redirected_to exam_groups_path
  end
end
