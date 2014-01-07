class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :predictions

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name:auth.extra.raw_info.name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20],
                          )
      end
    end
  end

  
  def prediction_for(match)
    predictions.find_by(match: match)
  end
  alias_method :has_predicted?, :prediction_for

  def match_predictions
    Match.all.map do |match|
      if has_predicted?(match)
        prediction_for(match)
      else
        Prediction.new(match: match, user: self)
      end
    end
  end
  
  def past_predictions
    past_predictions = Match.all.map do |match|
      if has_predicted?(match) && match.match_finished?
        prediction_for(match)
      end
    end
    return past_predictions.flatten
  end

  def user_points
    self.total_points = Prediction.this_season.sum(:points)
    save
    # total_points = self.total_points
    # x = 
    # new_total_points = total_points + x
    # self.update(total_points: new_total_points)

  end

end
