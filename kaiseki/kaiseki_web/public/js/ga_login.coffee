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
page.onUnsupportedContentReceived = (response) ->
  page.saveUnsupportedContent('history.tsv', response.id)

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
    page.open("https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja")

actions.add
  name: "login"
  render: true  #自動でlogin.pngとしてキャプチャ撮る
  before: ->
    # evaluateで参照する用のオブジェクトを定義し、return
    user_id: USER_ID
    password: PASSWORD
  evaluate: (params) ->
    # beforeの返り値をparamsとして受け取っている

    # 開いたページ内での処理(jQuery読み込み済み)
    document.querySelector("#Email").value = params.user_id
    document.querySelector("#Passwd").value = params.password
    document.querySelector("#gaia_loginform").submit()
    # $("#Email").val(params.user_id)
    # $("#Passwd").val(params.password)
    # $("#gaia_loginform").submit()

actions.add
  name: "first_link"
  delay: 1000
  render: true
  before: ->
    from_date: FROM_DATE
    to_date: TO_DATE
  evaluate: (params) ->
    # タイトルを表示(onConsoleMessageを定義してるから出力を確認出来る)
    # console.log $( "title" ).text()
    console.log document.title
    # from_date: params.from_date
    # to_date: params.to_date
    # base_url: 'https://www.google.com/analytics/web/?hl=ja&pli=1#report/visitors-overview/a36581569w64727418p66473324/'
    # console.log location.href
    xresult = document.evaluate('//*[@id="8-row-a36581569w64727418p66473324"]/td[2]/div/div/a', document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null)
    e = document.createEvent('MouseEvents')
    e.initEvent('click',false,true)
    # document.getElementById('ID-accountTable').dispatchEvent(e)
    # xresult = document.evaluate('//*[@id="8-row-a36581569w64727418p66473324"]/td[2]/div/div/a', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
    # xresult = document.evaluate('//*[@id="8-row-a36581569w64727418p66473324"]/td[2]/div/div/a', document, null, 9, null)
    console.log xresult
    console.log xresult.snapshotItem(0)
    xresult.snapshotItem(0).dispatchEvent(e)
    console.log xresult.snapshotLength
    # console.log xresult.snapshotLength
    # console.log xresult.singleNodeValue
    # after_url: xresult.singleNodeValue
    # xresult.singleNodeValue.click()
    # xresult.singleNodeValue.click();
  # after: (result) ->
  #   phantom.exit()
    # URLを指定して開く
    # page.open(result.after_url)
    # console.log result.base_url
    # console.log result.from_date
    # console.log result.to_date
    # page.open('https://www.google.com/analytics/web/?hl=ja&pli=1#report/visitors-overview/a36581569w64727418p66473324/')
    # page.open('https://www.google.com/analytics/web/?hl=ja&pli=1#report/visitors-overview/a36581569w64727418p66473324/%3F_u.date00%3D20121001%26_u.date01%3D20130430')
    # page.open(result.base_url + '%3F_u.date00%3D' + result.from_date + '%26_u.date01%3D' + result.to_date)
    # afterで参照する用のオブジェクトを定義し、return
    # titles: titles
#  after: (result) ->
    # evaluateの返り値をresultとして受け取っている

    # ファイルに書き込み
 #   fs.write "result.json", JSON.stringify(result.titles), true

actions.add
  name: "filter_set_start"
	delay: 1000
	render: true
	evaluate: ->
    console.log document.title
    # e = document.createEvent('MouseEvents')
    # e.initEvent('click',false,true)
    # document.getElementById('#ID-overview-graphOptions > div._GAK1b > div._GAPdb > div._GACEb > div > div.ID-buttonText._GAa-_GAs-_GAt._GAef').dispatchEvent(e)


# actions.add
# 	name: "filter_set_2"
# 	evaluate ->
# 		$.xfind("").click()
		
# actions.add
# 	name: "filter_set_end"
# 	evaluate ->
# 		$.xfind("").click()

# actions.add
# 	name: "tsv_download_start"
# 	delay: 2000
# 	render: true
# 	evaluate ->
# 		$.xfind("").click()

# actions.add
# 	name: "tsv_download_end"
# 	evaluate ->
# 		$.xfind("").click()
		
actions.run()
