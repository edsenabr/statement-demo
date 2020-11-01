#!/bin/bash
###############################################################################
# auto complete configuration; source this file to enable it
###############################################################################

AUTOCOMPLETE_OPTIONS='{
	"metrics": {
      "ingestion": null,
      "search": null
	},
	"batch-size": null,
	"searchable-documents": null
}'
CURRENT_DIR=$(dirname ${BASH_SOURCE[-1]})
. $CURRENT_DIR/../autocomplete-helper.sh

# stop processing if we're being sourced (autocomplete)
return 0 2>/dev/null

_usage() {
	echo "
invalid option: $1

	source $me for enabling auto-complete then
	$me <tab><tab>

valid options:

	$me metrics [search|ingestion] {run} {start} {finish}:
		collects the metrics bewtween {start} and {finish}, generates a CSV
		and plots a graph with those metrics. Those timestamps must be provided
		on the ISO 8601 format. {run} is the label that identifies the test on
		the spreadsheet and will be used on graph's title. 

	$me batch-size {start} {finish}:
		displays the average batch ingestion size between {start} and {finish}

	$me searchable-documents {start} {finish}:
		displays the number of searchable documents on elasticsearch between 
		 {start} and {finish}.

"

}
me=$0
action=$1
item=$2
parameter=$3

if [[ "$item" == "all" ]]; then
	shift 2
	for key in $(jq -r 'keys | .[] | scan("^((?!all).+)$") | @tsv' <<<$PROJECTS); do
		$me $action $key $*
	done
	exit
fi

case $action in

	"metrics")
		metrics='[
			{
				"Id": "m1",
				"Label": "CPU (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "CPUUtilization",
						"Dimensions": [
							{"Name": "DomainName", "Value": "statement-demo"},
							{"Name": "ClientId", "Value": "837108680928"}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m2",
				"Label": "CPU (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "CPUUtilization",
						"Dimensions": [
							{"Name": "DomainName", "Value": "statement-demo"},
							{"Name": "ClientId", "Value": "837108680928"}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m3",
				"Label": "JVM (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "JVMMemoryPressure",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m4",
				"Label": "JVM (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "JVMMemoryPressure",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m5",
				"Label": "SysMemory (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SysMemoryUtilization",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m6",
				"Label": "SysMemory (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SysMemoryUtilization",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m7",
				"Label": "Indexing (Sum)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "IndexingRate",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Sum"
				},
				"ReturnData": true
			},
			{
				"Id": "m8",
				"Label": "Search (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SearchRate",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m9",
				"Label": "SearchLatency (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SearchLatency",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m10",
				"Label": "SearchLatency (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SearchLatency",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m11",
				"Label": "IndexingLatency (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "IndexingLatency",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m12",
				"Label": "IndexingLatency (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "IndexingLatency",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m13",
				"Label": "ThreadpoolWriteQueue (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "ThreadpoolWriteQueue",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m14",
				"Label": "ThreadpoolWriteQueue (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "ThreadpoolWriteQueue",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m15",
				"Label": "ThreadpoolSearchQueue (Max)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "ThreadpoolSearchQueue",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
				"Id": "m16",
				"Label": "ThreadpoolSearchQueue (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "ThreadpoolSearchQueue",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			},
			{
				"Id": "m17",
				"Label": "Searchable Documents",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SearchableDocuments",
						"Dimensions": [
							{
								"Name": "DomainName",
								"Value": "statement-demo"
							},
							{
								"Name": "ClientId",
								"Value": "837108680928"
							}
						]
					},
					"Period": 60,
					"Stat": "Maximum"
				},
				"ReturnData": true
			},
			{
      	"Id": "e1",
      	"Expression": "RATE(m17)*60",
      	"Label": "Ingestion Rate",
				"Period": 60,
				"ReturnData": true
    	}			
		]
		'
		header=$(jq -c '["Timestamp", (.[] |  .Label)]' <<<$metrics)
		type=$2
		run=$3
		start=$(date -d $4 +'%s')
		finish=$(date -d $5 +'%s')
		# aws cloudwatch get-metric-data \
		# 	--scan-by TimestampAscending \
		# 	--start-time $start \
		# 	--end-time $finish \
		# 	--metric-data-queries "$metrics" \
		# 	| jq -r "$header,([.MetricDataResults[1].Timestamps, .MetricDataResults[].Values] | transpose | .[]) | @csv" > metrics-$type-$run.csv
		gnuplot -c infra/cloudwatch/$type.plot $run $start $finish
	;;

	"batch-size")
		query='fields log
			| filter log like /LancamentoListRepositoryImpl.save - Records so far/
			| parse log /(?<date>\d{2}-\d{2}-\d{4}) (?<time>\d{2}:\d{2}:\d{2}.\d{3}).+added (?<records>\d+),/
			| sort by time asc
			| earliest(date) as start_date, earliest(time) as start, latest(date) as end_date, latest(time) as end, ((latest(@timestamp) - earliest(@timestamp))/1000) as duration,  count(time) as requests, sum(records) as total, sum(crt) as created, sum(upd) as updated, sum (err) as errors, avg(records) as batch_size
		'
		id=$(aws logs  start-query --log-group-name '/aws/containerinsights/statement-demo/application' --start-time $2 --end-time $3 --query-string "$query" --query 'queryId' --output text)
		#id="825db7ba-c620-4d1b-9f7a-7c706f28a9d2"
		echo $id
		while [[ $status != "Complete" ]]; do 
			sleep 1
			results=$(aws logs get-query-results --query-id $id)
			status=$(jq -r '.status' <<<$results)
			echo $status
		done;
		jq -r '[.results[][] | .value] | @tsv' <<<$results \
			| awk '{print $1"T"$2, $3"T"$4, $8}' \
			| sed -e 's/\./,/g' -re 's/([0-9]{2})\-([0-9]{2})\-([0-9]{4})/\3-\2-\1/g'
	;;

	"searchable-documents")
		metrics='[
			{
				"Id": "m1",
				"Label": "CPU (Avg)",
				"MetricStat": {
					"Metric": {
						"Namespace": "AWS/ES",
						"MetricName": "SearchableDocuments",
						"Dimensions": [
							{"Name": "DomainName", "Value": "statement-demo"},
							{"Name": "ClientId", "Value": "837108680928"}
						]
					},
					"Period": 60,
					"Stat": "Average"
				},
				"ReturnData": true
			}
		]'
		header=$(jq -c '["Timestamp", (.[] |  .Label)]' <<<$metrics)
		aws cloudwatch get-metric-data \
			--start-time $2 \
			--end-time $3 \
			--scan-by TimestampAscending \
			--metric-data-queries "$metrics" \
			| jq -r "[.MetricDataResults[].Timestamps, .MetricDataResults[].Values] | transpose | .[] | {(.[0]): .[1]}"

	;;

	*)
		_usage $1
	;;

esac;
