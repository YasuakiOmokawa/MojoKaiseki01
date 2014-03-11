system = require("system")
USER_ID = system.args[1]
PASSWORD = system.args[2]
FROM_DATE = "20121001"
TO_DATE = "20130430"

# initialize {{{
page = require("webpage").create()
fs = require("fs")

page.onConsoleMessage = (msg) -> console.log("CONSOLE: " + msg)

# ページが読み込まれたら page.onCallback を呼ぶ#
page.onInitialized = ->
  page.evaluate ->
    document.addEventListener "DOMContentLoaded", ->
      window.callPhantom("DOMContentLoaded")
    , false

# Content-Disposition: attachment なレスポンスが返された時に呼び出されるコールバック
# page.onUnsupportedContentReceived = (response) ->
#   page.saveUnsupportedContent('history.tsv', response.id)

class Actions
  actions: []

  constructor: ->
    page.onCallback = (data) =>
      @run() if (data == "DOMContentLoaded")

  # アクションを追加
  add: (action) ->
    action.name ?= ""
    action.render ?= false
    action.delay ?= 0
    action.before ?= (-> {})
    action.evaluate ?= ((obj) -> {})
    action.after ?= ((obj) -> {})
    @actions.push action

  # アクションを順に実行
  run: ->
    action = @actions.shift()

    unless action?
      phantom.exit()
      return

    # 指定ミリ秒数待ってから実行
    setTimeout =>
      console.log "=============================="
      console.log " #{action.name}"
      console.log "=============================="

      if action.render
        page.render("#{action.name}.png")

      before_result = action.before()

      # 各ページでライブラリを読み込む
      # page.injectJs 'http://code.jquery.com/jquery-2.1.0.min.js'
      # page.injectJs "libs/jquery.cookie.js"
      # page.injectJs "libs/javascript-xpath-latest.js"
      # page.injectJs "libs/xpath4jquery-latest.js"
	  
      # 開いているページ内でaction.evaluateを実行
      # action.beforeの結果を引数として受け取り、返り値をaction.afterの引数にする
      evaluate_result = page.evaluate action.evaluate, before_result

      action.after(evaluate_result)

      if @actions.length == 0
        phantom.exit()

    , action.delay
# }}}

###
  以下、ログインしてスクレイピング
###

actions = new Actions

actions.add
  name: "start"
  after: ->
    # URLを指定して開く
    page.viewportSize = { width: 768, height: 1270 }
    page.open 'http://www.torrent-anime.com/'

actions.add
  name: "first_link"
  delay: 1000
  render: true
  before: ->
    from_date: FROM_DATE
    to_date: TO_DATE
  evaluate: (params) ->
    console.log document.title
    # xresult = document.evaluate('//*[@id="wpLoadingButton"]', document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null)
    # document.querySelector('div#wpLoadingButton')
    result = document.querySelector('div#wpLoadingButton')
    console.log result.offsetLeft
    console.log result.offsetTop
    evt = document.createEvent("MouseEvents")
    evt.initEvent("click", false, false)
    result.dispatchEvent(evt)
    # offset_left: result.offsetLeft
    # offset_top: result.offsetTop

    # base_url: res_url
  # after: (result) ->
    # url = encodeURI(result.base_url)
    # url = result.base_url
    # page.open url
    # console.log 'Result_url is ' + url
    # page.open 'https://www.google.com/analytics/web/?hl=ja#report/visitors-overview/a36581569w64727418p66473324/'
    # page.sendEvent('click', result.offset_left, result.offset_top)
    
actions.add
  name: "second_link"
  delay: 2000
  render: true
  evaluate: ->
    console.log document.title
		
actions.run()
