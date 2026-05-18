#!/bin/bash

current_date="$(date '+%Y-%m-%d')"

if [ ! -f "/root/task1/logs/metrics_$current_date" ]; then
	touch /root/task1/logs/metrics_$current_date.log
fi

LOG_FILE=/root/task1/logs/metrics_$current_date.log
HEAD_FILE=$'TIMESTAMP\t  | CPU_1min | CPU_5min | CPU_15min | MemTotal\t | MemAvailable\t | MemFree\t | DiskUsed%'

if [ ! -w "$LOG_FILE" ]; then
	exit 2
else
	echo "$HEAD_FILE" >> $LOG_FILE
fi

collection_metrics () {
	mydate="$(date '+%Y-%m-%d %H:%M:%S')"

	if [ ! -e "/proc/loadavg" ]; then 
		echo "File not exists" >&2
		exit 1
	else
		read -r cpu_1min cpu_5min cpu_15min _ < /proc/loadavg
	fi

	if [ ! -e "/proc/meminfo" ]; then
		echo "File not exists" >&2
		exit 1
	else
		mem_total="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
		mem_free="$(awk '/^MemFree:/ {print $2}' /proc/meminfo)"
		mem_available="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"
	fi

	disk_used="$(df -h | awk '$NF == "/" {print $5}')"
	echo -e "$mydate   $cpu_1min \t $cpu_5min \t  $cpu_15min \t  $mem_total \t  $mem_available \t  $mem_free \t   $disk_used"
}

catch_signal () {
	echo "Shutting down metric collector"
	exit 0
}

if [[ "$1" == "--daemon" && "$2" == "--interval" ]]; then
	echo "You entered interval mode"
	interval="$3"
	while true;
	do
		if [ ! -w "$LOG_FILE" ]; then 
			exit 2
		else
			collection_metrics >> "$LOG_FILE" 
		fi
		sleep $interval;
	done &
elif [ "$1" == "--daemon" ]; then
	echo "You entered daemon mode"
	while true;
	do
		trap catch_signal INT TERM EXIT
		if [ ! -w "$LOG_FILE" ]; then
			exit 2
		else
			collection_metrics >> "$LOG_FILE" 
		fi
		sleep 10
	done &
else
	echo "You entered single mode"
	result=$(collection_metrics)
	echo "$HEAD_FILE"
	echo "$result"
fi
