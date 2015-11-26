require 'rails_helper'

RSpec.describe QuestionBank::QuestionRecord, type: :model do
  describe "单选题" do
    before :all do
      @question = create :single_choice_question_wugui
      @user     = create(:user)
    end
    describe "回答正确" do
      before :all do
        @choice_answer = [["一条", false], ["两条", false], ["三条", false], ["四条", true]]
        @record = @question.question_records.create(
          :user          => @user,
          :answer        => @choice_answer
        )
      end

      it{
        expect(@record.valid?).to eq(true)
      }

      it{
        expect(@record.kind).to eq(@question.kind)
      }

      it{
        expect(@record.is_correct?).to eq(true)
      }

      it{
        expect(@record.bool_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.fill_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(@choice_answer)
      }
    end

    describe "回答错误" do
      before :all do
        @choice_answer = [["一条", true], ["两条", false], ["三条", false], ["四条", false]]
        @record = @question.question_records.create(
          :user          => @user,
          :answer => @choice_answer
        )
      end

      it{
        expect(@record.valid?).to eq(true)
      }

      it{
        expect(@record.kind).to eq(@question.kind)
      }

      it{
        expect(@record.is_correct?).to eq(false)
      }

      it{
        expect(@record.bool_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.fill_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(@choice_answer)
      }
    end

    describe "choice_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :essay_answer => "abc",
          :fill_answer => ["bcd"],
          :mapping_answer => [["一条", "jjs"], ["两条", "kcd"], ["三条", "kcb"], ["ddc", "ddcs"]],
          :bool_answer => true
        }

        answer_fields.each do |field|
          choice_answer = [["一条", true], ["两条", false], ["三条", false], ["四条", false]]
          record = @question.question_records.create(
            :user   => @user,
            :answer => choice_answer,
            field[0] => field[1]
          )

          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end

    describe "答案格式不正确" do
      before :all do
        @choice_answers = [
          ["1"],
          [[true,"true"]],
          [["一条", true], ["两条", false], ["三条", false], ["四条", true]]
        ]
      end

      it{
        @choice_answers.each do |answer|
          record = @question.question_records.create(
            :user   => @user,
            :answer => answer
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[:answer]).to be_nil
        end
      }
    end
  end

  describe "多选题" do
    before :all do
      @question = create :multi_choice_question_xiaochao
      @user     = create(:user) 
    end
    describe "回答正确" do 
      before :all do 
        @choice_answer = [["一条", false], ["两条", true], ["三条", true], ["四条", true], ["五条", true]]
        @record = @question.question_records.create(
          :user   => @user,
          :answer => @choice_answer
        )
      end 
      it{
        expect(@record.valid?).to eq(true)
      }
      it{
        expect(@record.kind).to eq(@question.kind)
      }
      it{
        expect(@record.is_correct).to eq(true)
      }
      it{
        expect(@record.bool_answer).to eq(nil)
        expect(@record.fill_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.choice_answer).to eq(@choice_answer)
      }
    end
    describe "回答错误" do
      before :all do
        @choice_answer = [["一条", false], ["两条", false], ["三条", true], ["四条", true], ["五条", true]]
        @record = @question.question_records.create(
          :user   => @user,
          :answer => @choice_answer
        )
      end
      it{
        expect(@record.valid?).to eq(true)
      }
      it{
        expect(@record.kind).to eq(@question.kind)
      }
      it{
        expect(@record.is_correct).to eq(false)
      }
      it{
        expect(@record.fill_answer).to eq(nil)
        expect(@record.bool_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.choice_answer).to eq(@choice_answer)
      }
    end
    describe "choice_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :essay_answer   => "Yes,he has two legs",
          :fill_answer    => ["a leg"],
          :bool_answer    => true,
          :mapping_answer => [["a","leg"],["two","legs"]]
        }
        answer_fields.each do |field|
          choice_answer = [["一条", false], ["两条", false], ["三条", true], ["四条", true], ["五条", true]]
          record = @question.question_records.create(
            :user    => @user,
            :answer  => choice_answer,
            field[0] => field[1]
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end
    describe "答案格式不正确" do
      it{
        choice_answer = [
          ["leg"],
          [[true,"two legs"]],
          [["一条", false], ["两条", false], ["三条", false], ["四条", false], ["五条", true]]
        ]
        choice_answer.each do |answer|
          record = @question.question_records.create(
            :user  => @user,
            :answer => answer
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[:answer]).to be_nil
        end
      }
    end
  end

  describe "填空题" do 
    before :all do
      @question = create :fill_question_say_hello
      @user     = create(:user)
    end
    describe "回答正确" do
      before :all do
        @fill_answer = ["北京", "伦敦"]
        @record      = @question.question_records.create(
          :user   => @user,
          :answer => @fill_answer
        )
      end
      it{
        expect(@record.valid?).to eq(true)
      }
      it{
        expect(@record.kind).to eq(@question.kind)
      }
      it{
        expect(@record.is_correct).to eq(true)
      }
      it{
        expect(@record.bool_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.fill_answer).to eq(@fill_answer)
      }
    end

    describe "回答错误" do
      before :all do
        @fill_answer = ["上海", "苏格兰"]
        @record      = @question.question_records.create(
          :user   => @user,
          :answer => @fill_answer
        )
      end
      it{
        expect(@record.valid?).to eq(true)
      }
      it{
        expect(@record.kind).to eq(@question.kind)
      }
      it{
        expect(@record.is_correct).to eq(false)
      }
      it{
        expect(@record.bool_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.fill_answer).to eq(@fill_answer)
      }
    end
  end
  # describe "连线题" do
  #   before :each do
  #     @id             = "2254879564145210"
  #     @kind           = "mapping"
  #     @mapping_answer = [["bbbb", "bbbb"], ["cccccc", "dddddd"]]
  #     @content        = "yyybby3331213131"
  #     @analysis       = nil
  #     @level          = 1
  #     @enabled        = true
  #     @question = QuestionBank::Question.create(id: @id, kind: @kind,mapping_answer: @mapping_answer, content: @content, analysis: @analysis, level: @level, enabled: @enabled )
  #   end
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = true
  #     @bool_answer          = nil
  #     @choice_answer        = nil
  #     @essay_answer         = nil
  #     @fill_answer          = nil
  #     @mapping_answer       = [["bbbb", "bbbb"], ["cccccc", "dddddd"]]
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db.user).to eq(@user)
  #     expect(@question_record_db.is_correct).to eq(@is_correct)
  #     expect(@question_record_db.bool_answer).to eq(@bool_answer)
  #     expect(@question_record_db.choice_answer).to eq(@choice_answer)
  #     expect(@question_record_db.essay_answer).to eq(@essay_answer)
  #     expect(@question_record_db.fill_answer).to eq(@fill_answer)
  #     expect(@question_record_db.mapping_answer).to eq(@mapping_answer)
  #   }
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = false
  #     @bool_answer          = nil
  #     @choice_answer        = nil
  #     @essay_answer         = nil
  #     @fill_answer          = nil
  #     @mapping_answer       = ["niao"]
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db).to eq(nil)
  #   }
  # end
  #
  # describe "论述题" do
  #   before :each do
  #     @id             = "2354879564145238"
  #     @kind           = "essay"
  #     @essay_answer   = "很关键"
  #     @content        = "论亲情"
  #     @analysis       = nil
  #     @level          = 1
  #     @enabled        = true
  #     @question = QuestionBank::Question.create(id: @id, kind: @kind, essay_answer: @essay_answer, content: @content, analysis: @analysis, level: @level, enabled: @enabled )
  #   end
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = true
  #     @bool_answer          = nil
  #     @choice_answer        = nil
  #     @essay_answer         = "很美好"
  #     @fill_answer          = nil
  #     @mapping_answer       = nil
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db.questions).to eq(@questions)
  #     expect(@question_record_db.user).to eq(@user)
  #     expect(@question_record_db.is_correct).to eq(@is_correct)
  #     expect(@question_record_db.bool_answer).to eq(@bool_answer)
  #     expect(@question_record_db.choice_answer).to eq(@choice_answer)
  #     expect(@question_record_db.essay_answer).to eq(@essay_answer)
  #     expect(@question_record_db.fill_answer).to eq(@fill_answer)
  #     expect(@question_record_db.mapping_answer).to eq(@mapping_answer)
  #   }
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = false
  #     @bool_answer          = nil
  #     @choice_answer        = nil
  #     @essay_answer         = nil
  #     @fill_answer          = nil
  #     @mapping_answer       = nil
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db).to eq(nil)
  #   }
  # end
  #
  # describe "判断题" do
  #   before :each do
  #     @id             = "2354879564145321"
  #     @kind           = "bool"
  #     @bool_answer    = true
  #     @content        = "阿黄是否小狗"
  #     @analysis       = nil
  #     @level          = 1
  #     @enabled        = true
  #     @question = QuestionBank::Question.create(id: @id, kind: @kind, bool_answer: @bool_answer, content: @content, analysis: @analysis, level: @level, enabled: @enabled )
  #   end
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = false
  #     @bool_answer          = false
  #     @choice_answer        = nil
  #     @essay_answer         = nil
  #     @fill_answer          = nil
  #     @mapping_answer       = nil
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db.questions).to eq(@questions)
  #     expect(@question_record_db.user).to eq(@user)
  #     expect(@question_record_db.is_correct).to eq(@is_correct)
  #     expect(@question_record_db.bool_answer).to eq(@bool_answer)
  #     expect(@question_record_db.choice_answer).to eq(@choice_answer)
  #     expect(@question_record_db.essay_answer).to eq(@essay_answer)
  #     expect(@question_record_db.fill_answer).to eq(@fill_answer)
  #     expect(@question_record_db.mapping_answer).to eq(@mapping_answer)
  #   }
  #
  #   it{
  #     @questions            = @question
  #     @user                 = create(:user)
  #     @is_correct           = true
  #     @bool_answer          = nil
  #     @choice_answer        = nil
  #     @essay_answer         = nil
  #     @fill_answer          = nil
  #     @mapping_answer       = nil
  #
  #     @question_record = QuestionBank::QuestionRecord.new(questions: @questions, user: @user, is_correct: @is_correct, bool_answer: @bool_answer, choice_answer: @choice_answer, essay_answer: @essay_answer, fill_answer: @fill_answer, mapping_answer: @mapping_answer )
  #
  #     @question_record.save
  #     @question_record.valid?
  #     @question_record_db = QuestionBank::QuestionRecord.where(:questions =>@questions).first
  #     expect(@question_record_db).to eq(nil)
  #   }
  # end

end
