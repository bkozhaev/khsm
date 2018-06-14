require 'rails_helper'

RSpec.describe GameQuestion, type: :model do

  let(:game_question) { FactoryBot.create(:game_question, a: 1, b: 2, c: 3, d: 4) }

  context 'game status' do
    it 'correct .variants' do
      expect(game_question.variants).to eq(
                                            {
                                                'a' => game_question.question.answer1,
                                                'b' => game_question.question.answer2,
                                                'c' => game_question.question.answer3,
                                                'd' => game_question.question.answer4
                                            }
                                        )
    end

    it 'correct .answer_correct?' do
      expect(game_question.answer_correct?('a')).to be_truthy
    end

    it 'correct .correct_answer_key' do
      expect(game_question.correct_answer_key).to eq("a")
    end

    it 'correct .level & .text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end
  end
end