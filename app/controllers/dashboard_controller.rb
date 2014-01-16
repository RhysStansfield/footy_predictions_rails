class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index 
    @predictions = current_user.match_predictions
    @results = current_user.past_predictions
    @scorers = Scorer.all.map { |scorer| scorer.name }
    @others_predictions = others_predictions
    @users = User.all.sort_by(&:total_points).reverse
    @groups = Group.all
    @users_group = user_group(current_user)
  end
  
  def join_group
    group = Group.find(params[:id])
    user = current_user
    user.update(group_id: group.id)
    redirect_to dashboard_path
  end
      
  def history
    @predictions = current_user.predictions.past
  end
  
  private
    def others_predictions
      User.all.map do |user| 
        unless user == current_user
          user.predictions.each do |prediction|
            prediction
          end  
        end
      end
    end
  
  def user_group user
    if user.group != nil
      return "Your current group: #{user.group.name}"
    else
      return "You are not currently a member of a group"
    end
  end
end