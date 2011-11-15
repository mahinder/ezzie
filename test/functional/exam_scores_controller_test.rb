require 'test_helper'

class ExamScoresControllerTest < ActionController::TestCase
  setup do
    @exam_score = exam_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exam_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exam_score" do
    assert_difference('ExamScore.count') do
      post :create, exam_score: @exam_score.attributes
    end

    assert_redirected_to exam_score_path(assigns(:exam_score))
  end

  test "should show exam_score" do
    get :show, id: @exam_score.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exam_score.to_param
    assert_response :success
  end

  test "should update exam_score" do
    put :update, id: @exam_score.to_param, exam_score: @exam_score.attributes
    assert_redirected_to exam_score_path(assigns(:exam_score))
  end

  test "should destroy exam_score" do
    assert_difference('ExamScore.count', -1) do
      delete :destroy, id: @exam_score.to_param
    end

    assert_redirected_to exam_scores_path
  end
end
