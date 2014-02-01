class Prediction < ActiveRecord::Base
  belongs_to :user
  belongs_to :match

  validates :match_id, uniqueness: {scope: :user_id}, presence: true
  validates :user_id, presence: true
  validates :home_prediction, presence: true, inclusion: { in: 0..9 }
  validates :away_prediction, presence: true, inclusion: { in: 0..9 }
  validates :first_goalscorer, presence: true

  scope :past, -> {joins(:match).where('match_date_time < ?', DateTime.now)}
  scope :future, -> {joins(:match).where('match_date_time > ?', DateTime.now)}
  scope :this_season, -> do
    if Time.now.month > 6
      start_year = Time.now.year
    else
      start_year = 1.year.ago.year
    end
    end_year = start_year + 1

    startpoint = DateTime.new(start_year, 7, 1)
    endpoint = DateTime.new(end_year, 6, 1)

    joins(:match).where('match_date_time < ? AND match_date_time > ?', endpoint, startpoint)
  end


  def assign_points
    if self.match.match_finished?
      points = score_points
      self.update(points: points)
    end
  end

  def score_points
    return 3 if exact_match?(prediction, actual)
    return 1 if result_correct?(prediction, actual)
    0
  end

  def prediction
    [self.home_prediction, self.away_prediction]
  end

  def actual
    [self.match.home_score, self.match.away_score]
  end

  def exact_match? prediction, actual
    (prediction[0] == actual[0]) and (prediction[1] == actual[1])
  end

  def result_correct? prediction, actual
    correct_draw_prediction?(prediction, actual) or 
    correct_away_win_prediction?(prediction, actual) or
    correct_home_win_prediction?(prediction, actual)
  end

  def correct_draw_prediction? prediction, actual
    draw?(*prediction) and draw?(*actual)
  end

  def correct_away_win_prediction? prediction, actual
    away_win?(*prediction) and away_win?(*actual)
  end

  def correct_home_win_prediction? prediction, actual
    home_win?(*prediction) and home_win?(*actual)
  end

  def draw? home_score, away_score
    score_analyser(home_score, away_score) == 0
  end

  def home_win? home_score, away_score
    score_analyser(home_score, away_score) > 0
  end

  def away_win? home_score, away_score
    score_analyser(home_score, away_score) < 0
  end

  def score_analyser home_score, away_score
    home_score - away_score
  end

end
