# 做题记录
class QuestionRecord
  constructor: (@$elm)->
    @bind_events()
    @$body_ele = @$elm.find(".record-tbody")

  set_body: (body)->
    @$body_ele.html(body)

  set_ajax: (record_kind,other_one,other_two)->
    if other_one == undefined
      record_url = record_kind
    else
      record_url = other_one
    jQuery.ajax
      url: "/question_records/#{record_url}",
      method: "GET",
      data: {kind: record_kind, second: other_two},
      dataType: "json"
    .success (msg) =>
      @set_body(msg.body)
    .error (msg) =>
      console.log( msg )

  set_delete_ajax: (id)->
    if confirm("确认删除吗？")
      if id.length == 24
        $.ajax
          url: "/question_records/#{id}",
          method: "DELETE",
          dataType: "json"
        .success (msg) =>
          @set_body(msg.body)
        .error (msg) =>
          console.log(msg)
      else
        $.ajax
          url: "/question_records/#{id}",
          method: "DELETE",
          data: {checked_ids: id}
          dataType: "json"
        .success (msg) =>
          @set_body(msg.body)
        .error (msg) =>
          console.log(msg)
    else
      console.log("已取消删除")

  bind_events: ->
    that = this
    # 加入错题本
    @$elm.on "click", ".record-table .insert-flaw", ->
      question_record_id = jQuery(this).closest(".insert-flaw").attr("data-question-record-id")
      jQuery.ajax
        url: "/question_flaws",
        method: "post",
        data: {question_records_id: question_record_id }
      .success (msg) ->
        window.location.reload()
      .error (msg) ->
        console.log(msg)

    # 删除做题记录
    @$elm.on "click", ".record-table .record-tbody .delete-record", ->
      record_id = $(this).closest(".delete-record").attr("data-question-record-id")
      that.set_delete_ajax(record_id)

    # 条件查询（时间: 某一时段内）
    @$elm.on "click", ".result-table .question-time-fragment", ->
      record_kind = jQuery(this).closest(".question-time-fragment").attr("data-kind")
      time_first = jQuery("#time_first").val()
      time_second = jQuery("#time_second").val()
      that.set_ajax(record_kind,time_first,time_second)

    # 全选
    @$elm.on "click", ".record-table .record-thead .th-record-check .flaw-checked-all", ->
      jQuery('.flaw-checked-all').change( ->
        checkboxes = jQuery(this).closest('.record-table').find(':checkbox')
        if jQuery(this).is(':checked')
          checkboxes.prop('checked', true)
        else
          checkboxes.prop('checked', false)
      )

    # 批量加入错题本
    @$elm.on "click", ".record-bottom .batch-into-flaw", ->
      checkedValues = $('input:checkbox:checked').map( ->
        this.value
      ).get()
      if checkedValues.length == 0
        alert("请选择条目")
      else
        $.ajax
          url: "/question_flaws",
          method: "POST",
          data: {question_records_id:  checkedValues, whether_batch:"batch_operation"},
        .success (msg) ->
          window.location.reload()
        .error (msg) ->
          console.log(msg)

    # 批量删除
    @$elm.on "click", ".record-bottom .batch-delete-record", ->
      checkedValues = $('input:checkbox:checked').map( ->
        this.value
      ).get()
      if checkedValues.length == 0
        alert("请选择条目")
      else
        that.set_delete_ajax(checkedValues)

# 错题本
class QuestionFlaw
  constructor: (@$elm)->
    @bind_events()
    @$body_ele = @$elm.find(".flaw_tbody")

  set_body: (body)->
    @$body_ele.html(body)

  set_ajax: (flaw_kind,other_one,other_two)->
    if other_one == undefined
      flaw_url = flaw_kind
    else
      flaw_url = other_one
    $.ajax
      url: "/question_flaws/#{flaw_url}",
      method: "GET",
      data: {kind: flaw_kind, second: other_two},
      dataType: "json"
    .success (msg) =>
      @set_body(msg.body)
    .error (msg) =>
      console.log(msg)

  set_delete_ajax: (id)->
    if confirm("确认删除吗？")
      if id.length == 24
        jQuery.ajax
          url: "/question_flaws/#{id}"
          method: "DELETE"
          dataType: "json"
        .success (msg) =>
          @set_body(msg.body)
        .error (msg) =>
          console.log(msg)
      else
        jQuery.ajax
          url: "/question_flaws/#{id}"
          method: "DELETE"
          data: {checked_ids: id}
          dataType: "json"
        .success (msg) =>
          @set_body(msg.body)
        .error (msg) =>
          console.log(msg)
    else
      console.log("已取消删除")


  bind_events: ->
    that = this
    # 删除记录
    @$elm.on "click", ".flaw-table .flaw-delete", ->
      flaw_id = jQuery(this).closest(".flaw-delete").attr("data-question-flaw-id")
      that.set_delete_ajax(flaw_id)

    # 条件查询（时间: 某一时段内）
    @$elm.on "click", ".result-table .flaw-time-fragment", ->
      flaw_kind = jQuery(this).closest(".flaw-time-fragment").attr("data-kind")
      time_first = jQuery("#time_first").val()
      time_second = jQuery("#time_second").val()
      that.set_ajax(flaw_kind,time_first,time_second)

    # 全选
    @$elm.on "click", ".flaw-table .flaw_thead .th_record_check .flaw-checked-all", ->
      jQuery('.flaw-checked-all').change( ->
        checkboxes = jQuery(this).closest('.flaw-table').find(':checkbox')
        if jQuery(this).is(':checked')
          checkboxes.prop('checked', true)
        else
          checkboxes.prop('checked', false)
      )

    # 批量删除
    @$elm.on "click", ".flaw-bottom .batch-delete-flaw", ->
      checkedValues = jQuery('input:checkbox:checked').map( ->
        this.value
      ).get()
      if checkedValues.length == 0
        alert("请选择条目")
      else
        that.set_delete_ajax(checkedValues)

jQuery(document).on 'ready page:load', ->
  if jQuery('.question-record').length > 0
    new QuestionRecord jQuery('.question-record')

  if jQuery('.question-flaw').length > 0
    new QuestionFlaw jQuery('.question-flaw')
