require 'enumerize'
require 'simple_form'
require 'csv'
require 'kaminari'
# 引用 rails engine
require 'question_bank/engine'
require 'question_bank/import_question'
require 'question_bank/import_question/parse_choice_line_methods'
require 'question_bank/import_question/parse_line'
require 'question_bank/import_question/parse_single_choice_line'
require 'question_bank/import_question/parse_multi_choice_line'
require 'question_bank/import_question/parse_bool_line'
require 'question_bank/import_question/parse_essay_line'
require 'question_bank/import_question/parse_fill_line'
require 'question_bank/import_question/parse_mapping_line'
require 'question_bank/import_question/parse_kind_error_line'

# 数字转中文数字
require 'question_bank/num_cn_conv'
Dir.glob(File.join(File.expand_path("../../",__FILE__), "app/models/question_bank/concerns/**.rb")).each do |file|
  require file
end
module QuestionBank
  mattr_accessor :user_class
end
