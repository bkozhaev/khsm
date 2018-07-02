require 'rails_helper'

RSpec.describe GameQuestion, type: :model do

  let(:game_question) {FactoryBot.create(:game_question, a: 1, b: 2, c: 3, d: 4)}

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

  context 'user helpers' do
    it 'correct audience_help' do
      expect(game_question.help_hash).not_to include(:audience_help)

      game_question.add_audience_help

      # проверим создание подсказки
      expect(game_question.help_hash).to include(:audience_help)

      # мы не можем знать распределение, но может проверить хотя бы наличие нужных ключей
      expect(game_question.help_hash).to include(:audience_help)
      ah = game_question.help_hash[:audience_help]
      expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
    end


    # проверяем работу 50/50
    it 'correct fifty_fifty' do
      # сначала убедимся, в подсказках пока нет нужного ключа
      expect(game_question.help_hash).not_to include(:fifty_fifty)
      # вызовем подсказку
      game_question.add_fifty_fifty

      # проверим создание подсказки
      expect(game_question.help_hash).to include(:fifty_fifty)
      ff = game_question.help_hash[:fifty_fifty]

      expect(ff).to include('a') # должен остаться правильный вариант
      expect(ff.size).to eq 2 # всего должно остаться 2 варианта
    end

    it 'correct friend_call' do
      #убедимся, в подсказках нет нужного ключа
      expect(game_question.help_hash).not_to include(:friend_call)
      #вызываем подсказку
      game_question.add_friend_call

      #проверим создание подсказки
      expect(game_question.help_hash).to include(:friend_call)
      fc = game_question.help_hash[:friend_call]
      expect(fc).to be
    end
  end
end