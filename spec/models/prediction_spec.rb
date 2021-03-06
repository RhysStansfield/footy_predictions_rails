require 'spec_helper'

describe Prediction do

  let(:prediction) { Prediction.new }

  def create_prediction_with(prediction=0, prediction2=0, actual=1, actual2=2, first_goalscorer="W. Rooney", match_time=(DateTime.now + 1.day))
    Prediction.new(home_prediction: prediction, away_prediction: prediction2, first_goalscorer: first_goalscorer,
      match: Match.new(home_score: actual, away_score: actual2, match_date_time: match_time))
  end

  def create_prediction
    FactoryGirl.create(:prediction)
  end

  context "time_cannot_be_after_match_time" do
    describe "created at is after match time" do
      it "should not create a Prediction" do
        match = FactoryGirl.create(:match, match_date_time: 1.day.ago)
        expect(create_prediction).to be false
      end
    end
    describe "created at is before match time" do
      it "should create a Prediction" do
        match = FactoryGirl.create(:match, match_date_time: (DateTime.now + 1.day))
        expect(create_prediction).to be true
      end
    end
  end
  
  context "matching the exact score" do
    it "returns 3 when predicted score (1-0) match actual score (1-0)" do
      expect(create_prediction_with(1,0,1,0).score_prediction_points).to be 3
    end

    it "returns 3 when predicted score (5-3) match actual score (5-3)" do
      expect(create_prediction_with(5,3,5,3).score_prediction_points).to be 3
    end

    it "returns 0 when predicted score (1-0) does not match the actual score (0-1)" do
      expect(create_prediction_with(1,0,0,1).score_prediction_points).to be 0
    end
  end

  context "correctly predicting the result" do 
    it "returns 1 when an Home win is correctly predicted but not the exact score" do
      expect(create_prediction_with(3,0,5,0).score_prediction_points).to be 1
    end

    it "returns 1 when an Away win is correctly predicted but not the exact score" do
      expect(create_prediction_with(0,3,0,5).score_prediction_points).to be 1
    end

    it "returns 1 when a Draw is correctly predicted but not the exact score" do
      expect(create_prediction_with(1,1,2,2).score_prediction_points).to be 1
    end

    it "returns 0 when both the score and the result are wrong" do
      expect(create_prediction_with(4,0,0,1).score_prediction_points).to be 0
    end

  end

  context "assigning points when match has finished" do

    before(:each) do
      match = FactoryGirl.create(:match)
    end

    it "assigns one point to a prediction if Home win correctly predicted but not exact score" do
      prediction = FactoryGirl.create(:prediction)
      prediction.match.stub(:match_finished?) { true }
      prediction.assign_points
      expect(prediction.points).to eq 1
    end

    it "assigns three points to a prediction if score and results are correctly guessed" do
      prediction = FactoryGirl.create(:correct_prediction)
      prediction.match.stub(:match_finished?) { true }
      prediction.assign_points
      expect(prediction.points).to eq 3
    end

    it "assigns zero points to a prediction if score and results are both incorrectly guessed" do
      prediction = FactoryGirl.create(:incorrect_prediction)
      prediction.match.stub(:match_finished?) { true }
      prediction.assign_points
      expect(prediction.points).to eq 0
    end

  end

  context "does not assign points when match has not finished" do

    before(:each) do
      match = FactoryGirl.create(:match)
    end

    it "does not assign one point to a prediction if home win correctly predicted but not exact score" do
      prediction = FactoryGirl.create(:prediction)
      prediction.match.stub(:match_finished?) { false }
      prediction.assign_points
      expect(prediction.points).to eq nil
    end

    it "does not assign three points to a prediction if score and results are correctly guessed" do
      prediction = FactoryGirl.create(:correct_prediction)
      prediction.match.stub(:match_finished?) { false }
      prediction.assign_points
      expect(prediction.points).to eq nil
    end

    it "does not assign zero points to a prediction if score and results are both incorrectly guessed" do
      prediction = FactoryGirl.create(:incorrect_prediction)
      prediction.match.stub(:match_finished?) { false }
      prediction.assign_points
      expect(prediction.points).to eq nil
    end

  end

  context "assigns points for scorer correctly" do 
    it "assigns one point to a prediction if the goalscorer is correct but the result is incorrectly predicted" do
      match = FactoryGirl.create(:match, first_goalscorer: "C. Player")
      prediction = FactoryGirl.create(:prediction, first_goalscorer: "C. Player")
      expect(prediction.first_scorer_points).to be 1
    end
  end


end
