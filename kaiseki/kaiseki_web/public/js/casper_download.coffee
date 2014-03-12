#!/usr/bin/env casperjs

casper = require('casper').create
	verbose: true
	loglevel: 'debug'
	pageSettings:
		"webSecurityEnabled": false
		"ignoreSslErrors": true
		"userAgent": 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:15.0) Gecko/20120427 Firefox/15.0a1'

# casper.options.waitTimeout = 2000
x = require('casper').selectXPath

casper.on 'load.failed', (resource) ->
	"use strict"
	@wait 1000, ->
		@echo "resource url is " + resource.url
		file = "stats.tsv"
		try
			# ...
			@echo "Attempting to download file " + file
			fs = require 'fs'
			casper.download(resource.url, fs.workingDirectory + '/' + file)
		catch e
			# ...
			@echo e

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
	@wait 2000, ->
		accessLog()
		@click 'div._GAg._GAoGb.ACTION-deepLink.TARGET-none'

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
			@click 'div.ID-compareConceptSelector._GAn1 input[type="checkbox"][class="ACTION-toggle TARGET-view"]'
				# @wait 10, ->
			# @evaluate -> document.querySelector('.ACTION-toggle.TARGET-view').checked
			@wait 10, ->
				@click 'div.ID-compareConceptSelector._GAn1 div[class*="goalConversionRate1"]'
			# __utils__.findAll('div.ID-compareConceptSelector._GAn1 div[class*="goalConversionRate1"]')
			# __utils__.findAll('div[class*="ID-concept-0-"] div[class*=goalConversionRate1"]')
				#ID-explorer-graphOptions > div._GAJ3b > div._GAuxb > div.ID-compareConceptSelector._GAn1 > div > div.ID-view._GAFcb._GAapb._GAH1b > div.ID-concept-0-12._GAje._GApqb.ACTION-select.TARGET-analytics\2e goalConversionRate1._GApd-_METRIC._GADl > div._GAUfb
				# @wait 2000, ->
				# 	@capture "tempcomplete.png"
				# 	@exit()

casper.then ->
	@echo "DOWNLOAD TSV"
	@wait 2000, ->
		accessLog()
		@click 'span.ID-exportControlButton._GAjc.ACTION-exportMenu.TARGET-'
		@click 'li.ACTION-export.TARGET-TSV'
		# @wait 10, ->
		# 	# __utils__.mouseEvent('click', 'li.ACTION-export.TARGET-TSV')
		# 	file = "stats.tsv"
		# 	file_url = 'https://www.google.com/analytics/web/exportReport?hl=ja&authuser=0&ef=TSV'
		# 	try
		# 		# ...
		# 		@echo "Attempting to download file " + file
		# 		fs = require 'fs'
		# 		casper.download(file_url, fs.workingDirectory + '/' + file)
		# 	catch e
		# 		# ...
		# 		@echo e


casper.then ->
	@echo "TEST COMPLETE"
	@wait 2000, ->
		accessLog()
		@capture "complete.png"
		@exit()

casper.run()


