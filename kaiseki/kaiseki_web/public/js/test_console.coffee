page = require("webpage").create()
url = "https://ja-jp.facebook.com/"
lib = "http://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"

page.onConsoleMessage = (msg)->
	console.log("console> #{msg}")

page.open url, (status)->
	page.includeJs lib, ->
		page.evaluate ->
			text = document.getElementsByTagName("html")[0].innerHTML
			console.log "evaluate: #{text}"
		phantom.exit()