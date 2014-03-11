#!/usr/bin/env casperjs

casper = require('casper').create
	verbose: true
	loglevel: 'debug'
casper.options.waitTimeout = 2000
x = require('casper').selectXPath

if casper.cli.args.length isnt 2
	casper.log 'Missing required argument. / USER PASS', 'error'
	casper.exit()

user_name = casper.cli.args[0]
user_pass = casper.cli.args[1]

accessLog = ()->
	casper.viewport 1024, 768
	casper.echo "================================"
	casper.echo casper.evaluate -> document.URL
	casper.echo "================================"

casper.start 'https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja', ->
	accessLog()

casper.then ->
	@echo "LOGIN"
	accessLog()
	@fill 'form#gaia_loginform',
		"Email": user_name
		"Passwd": user_pass
		, true

casper.then ->
	@echo "SELECT FIRST VIEW LINK"
	accessLog()
	@click 'div._GAJA._GAbV._GANV a'

casper.then ->
	@echo "DATE SETTINGS"
	accessLog()
	from_date = '20121001'
	to_date = '20130430'
	overview_url = @getCurrentUrl()
	date_url = '%3F_u.date00%3D' + from_date + '%26_u.date01%3D' + to_date + '/'
	@echo overview_url + date_url
	@open overview_url + date_url

casper.then ->
	@echo "SELECT DETAIL DATA LINK"
	@wait 1000, ->
		accessLog()
		@click x('//*[@id="ID-overview-dimensionSummary-miniTable"]/div/div')

casper.then ->
	@echo "SELECT CONVERSION"
	@wait 1500, ->
		accessLog()
		@click x('//*[@id="ID-explorer-graphOptions"]/div[1]/div[2]/div[4]/div/div[1]')
		@wait 10, ->
			@sendKeys 'input.ID-searchBox', '目標 1 のコンバージョン'
		# @wait 10, ->
			# if @exists '.ACTION-toggle.TARGET-view'
				# @echo 'checkbox identified'
			# @click '.ACTION-toggle.TARGET-view'
			# @click('input[type="checkbox"][className="ACTION-toggle TARGET-view"]')
				# @wait 10, ->
			# @evaluate -> document.querySelector('.ACTION-toggle.TARGET-view').checked
		@click 'div._GAUfb'


casper.then ->
	@echo "TEST COMPLETE"
	@wait 2000, ->
		accessLog()
		@capture "complete.png"
		@exit()

casper.run()


