#/bin/bash

source /home/webapp/.bash_profile


case $1 in 
	"start")
		phantomjs --ignore-ssl-errors=true --webdriver=4445 > /dev/null &
		echo "phantomjs started."
		break;;
	"stop")
		pids=(`ps -ef | grep phantomjs | grep -v grep | awk '{ print $2; }'`)
		for pid in ${pids[*]}
			do
				kill -9 ${pid}
			done
		break;;
	*)
		echo "usage: opePhantomJS.sh (start | stop)"
		break;;
esac

exit 0
