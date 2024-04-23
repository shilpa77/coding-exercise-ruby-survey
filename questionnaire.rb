class Questionnaire
  require "pstore" # https://github.com/ruby/pstore

  STORE_NAME = "tendable.pstore"
  @store = PStore.new(STORE_NAME)

  QUESTIONS = {
    "q1" => "Can you code in Ruby?",
    "q2" => "Can you code in JavaScript?",
    "q3" => "Can you code in Swift?",
    "q4" => "Can you code in Java?",
    "q5" => "Can you code in C#?"
  }.freeze

  # Accept survey answers
  def self.do_prompt
    answers = []
    # Ask each question and get an answer from the user's input.
    QUESTIONS.each_key do |question_key|
      print QUESTIONS[question_key]
      ans = gets.chomp.downcase
      answers << ans
    end

    save_answers_and_rating(answers)
  end

  # Print overall surveys report
  def self.do_report
    ratings = @store.transaction(true) { @store[:rating] }
    average_rating = (ratings.inject(0, :+))/ratings.length
    puts "Average ratings score: #{average_rating}"
  end

  private
    # Store survey answers and ratings in array format
    def self.save_answers_and_rating(answers)
      survey_rating = calculate_rating(answers)
      @store.transaction do
        @store[:answers] ||= []
        @store[:answers] << answers
        @store[:rating] ||= []
        @store[:rating] << survey_rating
      end
      # Current survey rating
      puts "Survey rating: #{survey_rating}"
    end

    def self.calculate_rating(answers)
      yes_count = answers.count { |answer| answer.start_with?('y') }
      total_questions = QUESTIONS.length
      (yes_count.to_f / total_questions * 100).round(2)
    end


end
Questionnaire.do_prompt
Questionnaire.do_report
