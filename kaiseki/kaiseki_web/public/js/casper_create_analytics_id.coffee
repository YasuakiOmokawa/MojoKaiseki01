#!/usr/bin/env casperjs
# Google Cloud Console へログインし、対象アカウントのapi有効化とアプリケーション生成、id取得までを行う

casper = require('casper').create
	verbose: true
	loglevel: 'debug'
	pageSettings:
		"webSecurityEnabled": false
		"ignoreSslErrors": true
		# "userAgent": 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:15.0) Gecko/20120427 Firefox/15.0a1'

x = require('casper').selectXPath

# 入力パラメータチェック  
if casper.cli.args.length isnt 2
	casper.log 'Missing required argument. / USER PASS', 'error'
	casper.exit()

user_name = casper.cli.args[0]
user_pass = casper.cli.args[1]

# 標準出力へ簡易ログの出力
accessLog = ()->
	casper.viewport 1024, 768
	casper.echo "================================"
	casper.echo casper.evaluate -> document.URL
	casper.echo "================================"

casper.start 'https://google.co.jp', ->
	accessLog()

# // casper.then ->
# // 	@echo "LOGIN"
# // 	accessLog()
# // 	@fill 'form#gaia_loginform',
# // 		"Email": user_name
# // 		"Passwd": user_pass
# // 		, true

# // casper.then ->
# // 	@echo "SELECT FIRST VIEW LINK"
# // 	accessLog()
# // 	@click 'div._GAJA._GAbV._GANV a'

# // casper.then ->
# // 	@echo "DATE SETTINGS"
# // 	accessLog()
# // 	from_date = '20121001'
# // 	to_date = '20130430'
# // 	overview_url = @getCurrentUrl()
# // 	date_url = '%3F_u.date00%3D' + from_date + '%26_u.date01%3D' + to_date + '/'
# // 	@echo overview_url + date_url
# // 	@open overview_url + date_url

# // casper.then ->
# // 	@echo "SELECT DETAIL DATA LINK"
# // 	accessLog()
# // 	casper.waitForSelector 'div._GAg._GAoGb.ACTION-deepLink.TARGET-none', -> 
# // 		@click 'div._GAg._GAoGb.ACTION-deepLink.TARGET-none'

# // casper.then ->
# // 	@echo "SELECT CONVERSION"
# // 	@wait 1500, ->
# // 		accessLog()
# // 		@click x('//*[@id="ID-explorer-graphOptions"]/div[1]/div[2]/div[4]/div/div[1]')
# // 		@wait 10, ->
# // 			@sendKeys 'input.ID-searchBox', '目標 1 のコンバージョン'
# // 			@click 'div.ID-compareConceptSelector._GAn1 input[type="checkbox"][class="ACTION-toggle TARGET-view"]'
# // 			@wait 10, ->
# // 				@click 'div.ID-compareConceptSelector._GAn1 div[class*="goalConversionRate1"]'

# // casper.then ->
# // 	@echo "DOWNLOAD TSV"
# // 	@wait 2000, ->
# // 		accessLog()
# // 		@click 'span.ID-exportControlButton._GAjc.ACTION-exportMenu.TARGET-'
# // 		# @click 'li.ACTION-export.TARGET-CSV' # ダウンロード開始のハズ
# // 		casper.evaluate ->
# // 			__utils__.mouseEvent('click', 'li.ACTION-export.TARGET-CSV')
# // 		# url = 'https://www.google.com/analytics/web/exportReport?hl=ja&authuser=0&ef=CSV'
# // 		# file = "stats.csv"
# // 		# try
# // 		# 	# ...
# // 		# 	@echo "Attempting to download file " + file
# // 		# 	fs = require 'fs'
# // 		# 	casper.download(url, fs.workingDirectory + '/' + file)
# // 		# catch e
# // 		# 	# ...
# // 		# 	@echo e

casper.then ->
	@echo "TEST COMPLETE"
	@wait 1000, ->
		accessLog()
		@capture "complete.png"
		@exit()

casper.run()