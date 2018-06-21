require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user)}

  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user)}

  context 'game mechanics' do
    it 'answer correct continues' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq q

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end

  context 'Game Factory' do
    it 'Game.create_game_for_user! new correct game' do
      generate_questions(60)
      game = nil


      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
          change(GameQuestion, :count).by(15)
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a

    end
  end

  context 'Take money' do
    it 'take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be >0

      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize

    end
  end

  context 'Checking .status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  context '#current_game_question' do
    it 'should return 1' do
      expect(game_w_questions.current_game_question.level).to eq(0)
    end
  end

  context '#previous_level' do
    it 'should return 0' do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  context '#answer_current_question!' do
    it 'should return false' do
      game_w_questions.time_out!
      expect(game_w_questions.answer_current_question!(0)).to be_falsey
    end

    it 'should return 1 (which means correct answer)' do
      game_w_questions.answer_current_question!('d')
      expect(game_w_questions.current_game_question.level).to eq(1)
    end

    it 'should not increment levels of the game' do
      game_w_questions.answer_current_question!('a')
      expect(game_w_questions.current_game_question.level).to eq(0)
    end

    it 'should finish the game' do
      game_w_questions.answer_current_question!('d')
      expect(game_w_questions.finished?).to be_falsy
    end
  end
end
