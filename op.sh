#!/bin/bash
###############################################################################
# auto complete configuration; source this file to enable it
###############################################################################
PROJECTS='{
  "all": null,
  "load-generate": null,
  "data-ingestion": null,
  "search": null
}'

ALL_PROJECTS='{
  "all": null,
  "load": null,
  "load-generate": null,
  "data-ingestion": null,
  "search": null
}'

AUTOCOMPLETE_OPTIONS='{
  "scale": '"$PROJECTS"',
  "pause": '"$PROJECTS"',
  "logs": '"$ALL_PROJECTS"',
  "kill": '"$PROJECTS"',
  "restart": '"$PROJECTS"',
  "deploy": '"$PROJECTS"',
	"config": '"$ALL_PROJECTS"',
	"exhibit": '"$PROJECTS"',
	"list": '"$PROJECTS"',
	"fire": {
      "config": null
	},
	"count": '"$ALL_PROJECTS"',
	"build": '"$ALL_PROJECTS"',
	"init-local": null
}'
CURRENT_DIR=$(dirname ${BASH_SOURCE[-1]})
. $CURRENT_DIR/autocomplete-helper.sh

# stop processing if we're being sourced (autocomplete)
return 0 2>/dev/null

_usage() {
	echo "
invalid option: $1

	source $me for enabling auto-complete then
	$me <tab><tab>

valid options:

	$me scale {name} {instances}:	scales the app to the # of instances
	$me pause {name}:			scales the app to 0 instances
	$me logs {name}:			follows the logs of the application
	$me kill {name}:			delete the application deployment
	$me restart {name}:			restart all the application pods 
	$me deploy {name} [config]:		applies the application deployment to the
						cluster. if config is provided, an editor
						will be opened for changing its properties.
	$me exhibit {name}:			display information about the application
	$me list {name}:			list the running pods for that application
	$me fire {name} [config]:		starts the ingestion process. if config is
						provided, before starting thr process will
						display an editor for configuring it. 
	$me count {name}:			count the application running instances
	$me build {name}:			compiles and pushes the application to ECR
	$me init-local {name}:		starts the local env using docker-coimpose

replace {name} with one of: 
	- data-ingestion:	writes data to elasticsearch
	- load-generate:	produces data to be written on elasticsearch
	- load:				generate account numbers
	- search:			run a predetermined search pattern against elasticsearch
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
	"scale")
		kubectl patch deploy $item -n $item --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/replicas\", \"value\":$parameter}]"
	;;

	"pause")
		kubectl patch deploy $item -n $item --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/replicas\", \"value\":0}]"
	;;

	"logs")
		
		[[ "$item" == "load" ]] && selector="job=$parameter" || selector="app=$item";
		
		while /bin/true; do
			set -x
			kubectl -n $item wait \
			--for=condition=Ready \
			--selector=$selector \
			--timeout=5s pods && \
				kubectl logs -f --selector=$selector -n $item --max-log-requests=60
			set +x
			sleep 1
		done;
	;;

	"kill")
		kubectl delete deploy -n $item $item
	;;

	"deploy")
		kubectl apply -f $item/$item.yaml
	;;

	"exhibit")
		kubectl describe deploy -n $item  $item
	;;

	"list")
		kubectl get pod --selector=app=$item --field-selector=status.phase=Running -n $item
	;;

	"restart")
		kubectl delete pod --selector=app=$item -n $item
	;;

	"fire")
		if [[ "$item" == "config" ]]; then
			$me config "load"
		fi
		#kubectl get cm some-config -o yaml | run 'sed' commands to make updates | kubectl create cm some-config -o yaml --dry-run | kubectl apply -f - 
		job_name=$(kubectl create -f load/load.yaml -o name | sed -e 's/.*\///')
		echo "created job $job_name"
		# $me logs load $job_name
	;;

	"config")
		kubectl edit cm -n $item application.properties
	;;

	"build")
		pushd $item
		if [[ "$item" != "jmeter" ]]; then
			mvn clean package
			if [ $? != 0 ]; then
					exit $ret_code
			fi
		fi

		docker build . -t 837108680928.dkr.ecr.us-east-1.amazonaws.com/$item:latest
		if [ $? != 0 ]; then
				exit $ret_code
		fi
		aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 837108680928.dkr.ecr.us-east-1.amazonaws.com
		if [ $? != 0 ]; then
				exit $ret_code
		fi
		docker push 837108680928.dkr.ecr.us-east-1.amazonaws.com/$item:latest
		if [ $? != 0 ]; then
				exit $ret_code
		fi
		popd
		#replicas=$(kubectl get deploy -n $item $item -o jsonpath='{.spec.replicas}')
		if [[ "$parameter" == "restart" ]]; then
			$me restart $item
		fi;
	;;
	"count")
		echo $item=$($me list $item | grep $item | wc -l)
	;;

	"init-local")
		docker-compose -p statement up -d
	;;

	"enable-monitor")
		instances=$(aws ec2 describe-instances --filters "Name=tag:eks:cluster-name,Values=statement-demo" --query 'Reservations[].Instances[].InstanceId' --output text)
		aws ec2 monitor-instances --instance-ids $instances
	;;

	*)
		_usage $1
	;;

esac;
