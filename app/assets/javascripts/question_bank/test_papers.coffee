class NewTestPaper
  constructor: (@$el, params) ->
    console.log 'NewTestPaper'
    @_init()
  
  _init: ->
    @$modal_random_questions = @$el.find('#modal-random-questions')
    @$modal_questions_selector = @$el.find('#modal-questions-selector')
    @$template_question = @$el.find('.template.question')
    @$template_section = @$el.find('.template.section')

    @set_scores()
    @_bind()

  _bind: ->
    that = this

    # section 大题操作
    @$el.on 'click', '.btn-random', ->
      $this = jQuery(this)
      that.$control_section = $this.parent().parent().parent().parent()

      # init
      that.$modal_random_questions.find('#input_random_count').val(5)
      that.$modal_random_questions.modal('show')

    @$el.on 'click', '.btn-choose', ->
      $this = jQuery(this)
      that.$control_section = $this.parent().parent().parent().parent()

      # 按等级读取题目，并根据已选初始化
      that.$modal_questions_selector.modal('show')

    @$el.on 'click', '.section_move_up', ->
      console.log 'section_move_up'
      $this = jQuery(this)
      $section = $this.parent().parent().parent()
      $section.insertBefore($section.prev()) if $section.prev().length > 0 
      # position 需要做调整

    @$el.on 'click', '.section_move_down', ->
      console.log 'section_move_down'
      $this = jQuery(this)
      $section = $this.parent().parent().parent()
      $section.insertAfter($section.next()) if $section.next().length > 0 and !$section.next().hasClass('empty')
      # position 需要做调整

    @$el.on 'click', '.section_destroy', ->
      console.log 'section_destroy'
      $this = jQuery(this)
      $section = $this.parent().parent().parent()
      $section.remove()
      # 删除后，还要重新计算大题数
      that.reset_section_title()

    @$el.on 'change', '.min_level', ->
      $this = jQuery(this)
      min = Number $this.val()
      $section = $this.parent().parent().parent().parent()
      $max = $section.find('.max_level')
      $max.children().each (index)->
        if index < min - 1
          jQuery(this).addClass('disabled').prop('disabled', true)
        else
          jQuery(this).removeClass('disabled').prop('disabled', false)
      
      $max.find(':not(.disabled)').first().prop('selected', true) if $max.find(':selected').hasClass('disabled')

    @$el.on 'change', '.max_level', ->
      $this = jQuery(this)
      max = Number $this.val()
      $section = $this.parent().parent().parent().parent()
      $min = $section.find('.min_level')
      $min.children().each (index)->
        if index >= max
          jQuery(this).addClass('disabled').prop('disabled', true)
        else
          jQuery(this).removeClass('disabled').prop('disabled', false)
      $min.find(':not(.disabled)').first().prop('selected', true) if $min.find(':selected').hasClass('disabled')

    # question 选题操作
    @$el.on 'click', '.question_move_up', ->
      $this = jQuery(this)
      $section = $this.parent().parent()
      $section.insertBefore($section.prev()) if $section.prev().length > 0 
      # todo position 需要做调整

    @$el.on 'click', '.question_move_down', ->
      $this = jQuery(this)
      $section = $this.parent().parent()
      $section.insertAfter($section.next()) if $section.next().length > 0 and !$section.next().hasClass('empty')
      # todo position 需要做调整

    @$el.on 'click', '.question_destroy', ->
      $this = jQuery(this)
      $section = $this.parent().parent()
      # 新建时，直接删除
      $section.remove()
      # todo 修改时， 设置_destroy 而非单纯移除  ????
      #$section.addClass('hidden')
      #$section.find('.destroy').val('true')

    # modal 弹窗操作
    @$modal_random_questions.on 'click', '.button-random-questions', =>
      random_count = Number @$modal_random_questions.find('#input_random_count').val()
      # todo 读取已选题目
      if random_count == NaN or random_count == 0
        alert('选择考题数量不为数字，或者不大于0')
      else
        # todo 传入已选题目, 不重复
        @get_random_questions
          section: @$control_section
          random_count: random_count

    @$modal_questions_selector.on 'click', '.button-questions-selector', =>
      $question = @$template_question.clone()
      $section_questions = @$control_section.find('.section_questions')
      $section_questions.children().remove()
      section_index = @$el.find('.sections .section').index(@$control_section)

      @$modal_questions_selector.find(':checked').each (index)->
        $this = jQuery(this)
        $label_question = $this.parent()
        question = $label_question.find('span').html()
        
        # haml 不知道为什么会转为-
        #question_id = $label_question.data('question_id')
        question_id = $label_question.data('question-id')

        str_template = $question.html().replace /{{content}}/g , question

        str_template = str_template.replace /{{section_index}}/g , section_index
        str_template = str_template.replace /{{question_index}}/g , index

        str_template = str_template.replace /{{question_id}}/g , question_id
        str_template = str_template.replace /{{position}}/g , index

        $template = jQuery(str_template).removeClass('hidden')
        $section_questions.append($template)

      @set_scores()
      @$modal_questions_selector.modal('hide')


    # 增加一个大题
    @$el.on 'click', '.btn-new-section', =>
      $section = @$template_section.clone()

      section_index = @$el.find('.sections .section').length

      #@$modal_questions_selector.find(':checked').each (index)->
        #$this = jQuery(this)
        #$label_question = $this.parent()
        #question = $label_question.find('span').html()
        
        ## haml 不知道为什么会转为-
        ##question_id = $label_question.data('question_id')
        #question_id = $label_question.data('question-id')

      str_template = $section.html().replace /{{section_index_plus}}/g , section_index + 1

      str_template = str_template.replace /{{section_index}}/g , section_index
      #str_template = str_template.replace /{{question_index}}/g , index

      #str_template = str_template.replace /{{question_id}}/g , question_id
      #str_template = str_template.replace /{{position}}/g , index

      $template = jQuery(str_template).removeClass('hidden')
      @$el.find('.sections').append($template)
    
    @$el.on 'blur', '#test_paper_score, .section_score', =>
      @set_scores()

  set_scores: ->
    @scores = Number @$el.find('#test_paper_score').val()
    @total = @calculate_total()
    @surplus = @scores - @total
    if @scores != NaN and @scores > 0
      @$el.find('.scores').html(@scores)
      @$el.find('.total').html(@total)
      @$el.find('.surplus').html(@surplus)
    else
      @$el.find('.scores').html('请先设置试卷总分')
      @$el.find('.total').html('请先设置试卷总分')
      @$el.find('.surplus').html('请先设置试卷总分')

  calculate_total: ->
    total = 0
    @$el.find('.sections .section').each ->
      $section = jQuery(this)
      score = Number $section.find('.section_score').val()
      if score != NaN and score > 0
        total += score * $section.find('ol li').length
    console.log total
    total

  get_random_questions: (params) ->
    console.log params
    {section, random_count} = params
    # ajax get_random_questions
    for i in [0..random_count-1]
      section.find('.section_questions').append('<li><div class="clearfix">测试</div></li>')
    @set_scores()
    @$modal_random_questions.modal('hide')

  reset_section_title: ->
    @$el.find('.sections .section').each (index)->
      $this1 = jQuery(this)
      $this1.find('h3').html("第#{index+1}大题")
      

jQuery(document).on 'ready page:load', ->
  new NewTestPaper(jQuery('.page-new-test_paper'), {}) if jQuery('.page-new-test_paper').length > 0
