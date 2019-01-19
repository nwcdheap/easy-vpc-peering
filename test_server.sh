#!/bin/bash

CONF=test.conf

err_quit() {
	echo "ERR_QUIT: $1"
	exit 1
}

validate_templates () {
	echo "Templates validation"
	for F in ${CHECK_FILES}; do
		echo "Check $F ......"
		aws cloudformation validate-template --template-body file://$F
		if [ $? -ne 0 ]; then
			echo "$F: Invalid format. Quit"
			exit 0
		fi
	done
}


server_setup() {
	## Setup EasyVPN Server in Seoul(Korea)
	aws --profile ${SERVER_PROFILE} --region ${SERVER_REGION} cloudformation create-stack  \
		--stack-name ${SERVER_StackName} \
		--template-body file://EasyVPN_Server.yaml \
		--capabilities CAPABILITY_IAM \
		--parameters \
			ParameterKey=InstanceType,ParameterValue=${SERVER_InstanceType} \
			ParameterKey=KeyName,ParameterValue=${SERVER_KeyName} \
			ParameterKey=VpcId,ParameterValue=${SERVER_VpcId} \
			ParameterKey=SubnetId,ParameterValue=${SERVER_SubnetId} \
			ParameterKey=PeerVPNSubnets,ParameterValue=\"${SERVER_PeerVPNSubnets}\"

	## Check status
	aws --profile ${SERVER_PROFILE} --region ${SERVER_REGION} cloudformation list-stacks --output json --stack-status-filter CREATE_IN_PROGRESS

	## Get output
    	#aws --profile ${SERVER_PROFILE} --region ${SERVER_REGION} cloudformation describe-stacks --stack-name ${SERVER_StackName}   --output json --query 'Stacks[*].Outputs[*]'
}

server_destroy() {
	aws --profile $PROFILE --region $REGION cloudformation delete-stack \
		--stack-name ${SERVER_StackName}
}


### Main
[ -f $CONF ] || err_quit "Missing $CONF"

. $CONF

CHECK_FILES="EasyVPN_Server.yaml"
validate_templates

PROFILE=${SERVER_PROFILE}
REGION=${SERVE_REGION}

server_setup
#server_destroy

exit 0


