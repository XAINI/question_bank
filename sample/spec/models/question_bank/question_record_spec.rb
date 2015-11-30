require 'rails_helper'

RSpec.describe QuestionBank::QuestionRecord, type: :model do
  describe "单选题" do
    before :all do
      @question = create :single_choice_question_wugui
      @user     = create(:user)
    end
    describe "回答正确" do
      before :all do
        @choice_answer = {"0" => ["一条", "false"], "1" => ["两条", "false"], "2" => ["三条", "false"], "3" => ["四条", "true"]}
        @record_before_count = QuestionBank::QuestionRecord.count
        @record = @question.question_records.create(
          :user          => @user,
          :answer        => @choice_answer
        )
        @record_after_count = QuestionBank::QuestionRecord.count
      end

      it{
        expect(@record_before_count + 1).to eq(@record_after_count)
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
        expect(@record.choice_answer).not_to be_nil
      }
    end

    describe "回答错误" do
      before :all do
        @choice_answer = {"0" => ["一条", "true"], "1" => ["两条", "false"], "2" => ["三条", "false"], "3" => ["四条", "false"]}
        @record_before_count = QuestionBank::QuestionRecord.count
        @record = @question.question_records.create(
          :user          => @user,
          :answer => @choice_answer
        )
        @record_after_count = QuestionBank::QuestionRecord.count
      end

      it{
        expect(@record_before_count + 1).to eq(@record_after_count)
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
        expect(@record.choice_answer).not_to be_nil
      }
    end

    describe "choice_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :essay_answer => "abc",
          :fill_answer => ["bcd"],
          :mapping_answer => [["狐狸", "犬科"], ["老虎", "猫科"]],
          :bool_answer => "true"
        }

        answer_fields.each do |field|
          choice_answer = {"0" => ["一条", "false"], "1" => ["两条", "false"], "2" => ["三条", "false"], "3" => ["四条", "true"]}
          record_before_count = QuestionBank::QuestionRecord.count
          record = @question.question_records.create(
            :user   => @user,
            :answer => choice_answer,
            field[0] => field[1]
          )
          record_after_count = QuestionBank::QuestionRecord.count
          expect(record_before_count).to eq(record_after_count)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end

    describe "答案格式不正确" do
      before :all do
        @choice_answers = [
          {"0" => ["1"]},
          {"0" => [true,"true"]},
          {"0" =>["一条", "true"], "1" => ["两条", "false"], "2" => ["三条", "false"], "3" => ["四条", "true"]}
        ]
      end
      it{
        @choice_answers.each do |answer|
          record_before_count = QuestionBank::QuestionRecord.count
          record = @question.question_records.create(
            :user   => @user,
            :answer => answer
          )
          record_after_count = QuestionBank::QuestionRecord.count
          expect(record_before_count).to eq(record_after_count)
          expect(record.errors.messages[:answer]).not_to be_nil
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
        @choice_answer = {"0" => ["一条", "false"], "1" => ["两条", "true"], "2" => ["三条", "true"], "3" => ["四条", "true"], "4" => ["五条", "true"]}
        @record_before_count = QuestionBank::QuestionRecord.count
        @record = @question.question_records.create(
          :user   => @user,
          :answer => @choice_answer
        )
        @record_after_count = QuestionBank::QuestionRecord.count
      end 
      it{
        expect(@record_before_count + 1).to eq(@record_after_count)
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
        expect(@record.choice_answer).not_to be_nil
      }
    end
    describe "回答错误" do
      before :all do
        @choice_answer = {"0" => ["一条", "false"], "1" => ["两条", "false"], "2" => ["三条", "true"], "3" => ["四条", "true"], "4" => ["五条", "true"]}
        @record_before_count = QuestionBank::QuestionRecord.count
        @record = @question.question_records.create(
          :user   => @user,
          :answer => @choice_answer
        )
        @record_after_count = QuestionBank::QuestionRecord.count
      end
      it{
        expect(@record_before_count + 1).to eq(@record_after_count)
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
        expect(@record.choice_answer).not_to be_nil
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
          choice_answer = {"0" => ["一条", "false"], "1" => ["两条", "true"], "2" => ["三条", "true"], "3" => ["四条", "true"], "4" => ["五条", "true"]}
          record_before_count = QuestionBank::QuestionRecord.count
          record = @question.question_records.create(
            :user    => @user,
            :answer  => choice_answer,
            field[0] => field[1]
          )
          record_after_count = QuestionBank::QuestionRecord.count
          expect(record_before_count).to eq(record_after_count)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end
    describe "答案格式不正确" do
      it{
        choice_answer = [
          {"0" => ["leg"]},
          {"0" =>[true,"two legs"]},
          {"0" => ["一条", "false"], "1" => ["两条", "false"], "2" => ["三条", "false"], "3" => ["四条", "false"], "4" => ["五条", "true"]}
        ]
        choice_answer.each do |answer|
          record_before_count = QuestionBank::QuestionRecord.count
          record = @question.question_records.create(
            :user  => @user,
            :answer => answer
          )
          record_after_count = QuestionBank::QuestionRecord.count
          expect(record_before_count).to eq(record_after_count)
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

    describe "fill_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :choice_answer => [["hello",true],["nihao",false]],
          :mapping_answer => [["hony","baby"],["coat","shirt"]],
          :bool_answer => true,
          :essay_answer => "Alan is a good man"
        }
        answer_fields.each do |field|
          fill_answer = ["北京", "伦敦"]
          record = @question.question_records.create(
            :user => @user,
            :answer =>fill_answer,
            field[0] => field[1]
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end

    describe "答案格式不正确" do 
      it{
        fill_answers = [
          [true,1452],
          [["北京"],["伦敦"]]
        ]
        fill_answers.each do |answer|
          record = @question.question_records.create(
            :user => @user,
            :answer => answer
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[:answer]).to be_nil
        end
      }
    end
  end

  describe "连线题" do 
    before :all do
      @question = create :mapping_question_letter
      @user = create(:user)
    end
    describe "回答正确" do
      before :all do
        @mapping_answer = {"0" => ["A","a"],"1" =>["B", "b"], "2" =>["C", "c"]}
        @record = @question.question_records.create(
          :user => @user,
          :answer => @mapping_answer
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
        expect(@record.fill_answer).to eq(nil)
        expect(@record.bool_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.mapping_answer).not_to be_nil
      }
    end

    describe "回答错误" do 
      before :all do 
        @mapping_answer = {"0" => ["A","b"],"1" =>["B", "c"], "2" =>["C", "a"]}
        @record = @question.question_records.create(
          :user => @user,
          :answer => @mapping_answer
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
        expect(@record.essay_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.mapping_answer).not_to be_nil
      }
    end 

    describe "mapping_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :fill_answer => ["peking"],
          :bool_answer => true,
          :essay_answer => "I love you sweet",
          :choice_answer => [["一条", false], ["两条", false], ["三条", false], ["四条", true]],
        }
        @mapping_answer = {"0" => ["A","a"],"1" =>["B", "b"], "2" =>["C", "c"]}
        answer_fields.each do |field|
          record = @question.question_records.create(
            :user => @user,
            :answer => @mapping_answer,
            field[0] => field[1]
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end

    describe "答案格式不正确" do
      it{
        mapping_answer = [
          {"0" => ["hello"]},
          {"0" => ["hei",true],"1" => [345,true]},
          {"0" => [nil,nil],"1" => [nil,nil]}
        ]
        mapping_answer.each do |answer|
          record_before_count = QuestionBank::QuestionRecord.count
          record = @question.question_records.create(
            :user => @user,
            :answer => answer
          )
          record_after_count = QuestionBank::QuestionRecord.count
          expect(record_before_count).to eq(record_after_count)
          expect(record.errors.messages[:answer]).to be_nil
        end
      }
    end
  end

  describe "论述题" do
    before :all do
      @question = create :essay_question_relative
      @user = create(:user)
    end

    describe "回答正确" do
      before :all do 
        @essay_answer = "很关键"
        @record = @question.question_records.create(
          :user => @user,
          :answer => @essay_answer
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
        expect(@record.fill_answer).to eq(nil)
        expect(@record.bool_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.essay_answer).to eq(@essay_answer)
      }
    end

    describe "回答错误" do 
      before :all do
        @essay_answer = "I don't know"
        @record = @question.question_records.create(
          :user => @user,
          :answer => @essay_answer
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
        expect(@record.choice_answer).to eq(nil)
        expect(@record.essay_answer).to eq(@essay_answer)
      }
    end

    describe "essay_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :bool_answer => true,
          :fill_answer => ["right"],
          :mapping_answer => [["A","a"],["B","b"]],
          :choice_answer => [["two",false],["four",false],["three",true],["one",false]]
        }
        @essay_answer = "很关键"
        answer_fields.each do |field|
          record = @question.question_records.create(
            :user => @user,
            :answer => @essay_answer,
            field[0] => field[1]
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end
  end

  describe "判断题" do
    before :all do 
      @question = create :bool_question_dog
      @user = create(:user)
    end

    describe "回答正确" do
      before :all do 
        @bool_answer = "true"
        @record = @question.question_records.create(
          :user => @user,
          :answer => @bool_answer
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
        expect(@record.fill_answer).to eq(nil)
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.bool_answer).not_to be_nil
      }
    end

    describe "回答错误" do
      before :all do
        @bool_answer = "false"
        @record = @question.question_records.create(
          :user => @user,
          :answer => @bool_answer
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
        expect(@record.mapping_answer).to eq(nil)
        expect(@record.choice_answer).to eq(nil)
        expect(@record.essay_answer).to eq(nil)
        expect(@record.bool_answer).not_to be_nil
      }
    end

    describe "bool_answer 字段之外的答案字段必须为 nil" do
      it{
        answer_fields = {
          :fill_answer => ["abc"],
          :mapping_answer => [["A","a"],["B","b"],["C","c"]],
          :choice_answer => [["jkl",true],["ghi",false],["def",false],["abc",false]],
          :essay_answer => "Hello world"
        }
        @bool_answer = true
        answer_fields.each do |field|
          record = @question.question_records.create(
            :user => @user,
            :answer => @bool_answer,
            field[0] => field[1]
          )
          expect(record.valid?).to eq(false)
          expect(record.errors.messages[field[0]]).not_to be_nil
        end
      }
    end
  end
end
