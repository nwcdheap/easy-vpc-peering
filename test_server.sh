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
	aws --profile $PROFILE --region $REGION cloudformation create-stack  \
		--stack-name EasyVPNServer \
		--template-body file://EasyVPN_Server.yaml \
		--capabilities CAPABILITY_IAM  \
		--parameters \
			ParameterKey=InstanceType,ParameterValue=t2.micro \
			ParameterKey=KeyName,ParameterValue=nx-test \
			ParameterKey=VpcId,ParameterValue=vpc-dc2ddeb5  \
			ParameterKey=SubnetId,ParameterValue=subnet-3bb67352

	## Check status
	aws --profile $PROFILE --region $REGION cloudformation list-stacks --output json --stack-status-filter CREATE_IN_PROGRESS

	## Get output
    aws --profile $PROFILE --region $REGION cloudformation describe-stacks --stack-name EasyVPNServer --output json --query 'Stacks[*].Outputs[*]'
}

server_destroy() {
	aws --profile $PROFILE --region $REGION cloudformation delete-stack \
		--stack-name EasyVPNServer
}


client_destroy() {
	aws --profile $PROFILE --region $REGION cloudformation delete-stack \
		--stack-name EasyVPNClient
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


