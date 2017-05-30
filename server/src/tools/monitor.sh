#!/bin/sh

#############################################################
# monitor server running									#
# restart server if detect it is not running				#
# monitor.sh must be in the same directory with the server	#
#############################################################

function monitor() {
	if [ ! -e *.conf ]
	then 
		echo "no config file"
		return
	fi

	if [ -e log*_1.txt ]; then
		while true
		do 
			file=`ls log*_1.txt`
			pid=`echo $file|awk -F_ '{print $2}'`  # get pid
			process_count=`ps aux|grep $1|grep $pid|wc -l`
			if [ $process_count == 0 ]
			then
				# send a SMS
                export APPLICATION_ENV=production
                #php /var/www/html/www.mogujie.com/appbeta/crond/crond.php Crond_Imserver::sendMsg
				
				# add log
				date >> restart.log
				echo "server stopped, pid=$pid, process_cnt=$process_count" >> restart.log
				
				# restart server
				mv log*.txt oldlog/
				../daeml ./$1
			fi

			sleep 15
		done
	fi
}

function monitor_business() {
	if [ $# != 1 ]; then 
		echo "./monitor.sh business port"
		exit
	fi

	while true 
	do 
		pid=`cat mogutalk.pid`
		process_count=`ps aux|grep mogutalk-business|grep $pid|wc -l`
		if [ $process_count == 0 ]
		then 
			# send a SMS
            export APPLICATION_ENV=production
            #php /var/www/html/www.mogujie.com/appbeta/crond/crond.php Crond_Imserver::sendMsg

			#add log
			date >> restart.log
			echo "server stopped, process_cnt=$process_count" >> restart.log

			# restart server
			./run.sh $1
		fi
		
		sleep 15
	done
}

case $1 in
	login_server)
		monitor $1
		;;
	msg_server)
		monitor $1
		;;
	route_server)
		monitor $1
		;;
	http_msg_server)
		monitor $1
		;;
	business)
		monitor_business $2
		;;
	*)
		echo "Usage: "
		echo "  ./monitor.sh (login_server|msg_server|route_server|http_msg_server|business port)"
		;;
esac

