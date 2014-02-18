page = require("webpage").create()
system = require "system"
userName = system.args[1]
password = system.args[2]

# phantom.injectJs('libs/javascript-xpath-latest.js')

callbacks = [
	-> # ログイン画面の処理
	page.evaluate ((userName, password) ->
		document.querySelector("#email").value = userName
		document.querySelector("#pass").value = userName
		document.querySelector("#login_form").submit()
		), userName, password

	# -> # すべてのウェブサイトのデータリンクをクリック
	# page.evaluate ->
	# 	e = document.createEvent('MouseEvents')
	# 	e.initEvent('click', false, true)
	# 	document.evaluate('//*[@id="9-row-a36581569w64727418p66473324"]/td[2]/div/div/a', document, null, 7, null).dispatchEvent(e)
]

counter = 0
page.onLoadFinished = ->
	counter = counter + 1
	page.render('scrrenshot' + counter + '.png')
	callback = callbacks.shift()
	phantom.exit() unless callback
	callback()

# Content-Disposision: attachment なレスポンスが返された時に呼び出されるコールバック
page.onUnsupportedContentReceived = (response) ->
	page.saveUnsupportedContent('pageviews.tsv', response.id)

page.open "https://www.facebook.com/"