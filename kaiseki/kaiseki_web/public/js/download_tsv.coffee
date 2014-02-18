page = (require 'webpage').create()
# phantom.injectJs('libs/javascript-xpath-latest.js')

callbacks = [
	-> # ログイン画面の処理
	page.evaluate ->
		document.getElementById('Email').value = ""
		document.getElementById('Passwd').value = ""
		e = document.createEvent('MouseEvents')
		e.initEvent('click', false, true)
		document.getElementById('signIn').dispatchEvent(e)

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

page.open 'https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja'
