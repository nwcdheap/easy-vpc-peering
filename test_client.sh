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

client_setup() {
	## Setup EasyVPN Client in Ningxia(China)
	aws --profile $PROFILE --region $REGION cloudformation create-stack  \
		--stack-name ${CLIENT_StackName} \
		--template-body file://EasyVPN_Client.yaml \
		--parameters \
			ParameterKey=InstanceType,ParameterValue=${CLIENT_InstanceType} \
			ParameterKey=KeyName,ParameterValue=${CLIENT_KeyName} \
			ParameterKey=VpcId,ParameterValue=${CLIENT_VpcId} \
			ParameterKey=SubnetId,ParameterValue=${CLIENT_SubnetId} \
			ParameterKey=VpcCIDR,ParameterValue=${CLIENT_VpcCIDR} \
			ParameterKey=VPNServerIP,ParameterValue=${CLIENT_VPNServerIP} \
			ParameterKey=PSK,ParameterValue=${CLIENT_PSK} \
			ParameterKey=PeerVPNSubnets,ParameterValue=\"${CLIENT_PeerVPNSubnets}\"

	## Check status
	aws --profile $PROFILE --region $REGION cloudformation list-stacks --output json --stack-status-filter CREATE_IN_PROGRESS

}

client_destroy() {
	aws --profile $PROFILE --region $REGION cloudformation delete-stack \
		--stack-name ${CLIENT_StackName}
}

### Main
[ -f $CONF ] || err_quit "Missing $CONF"

. $CONF

CHECK_FILES="EasyVPN_Client.yaml"
validate_templates

PROFILE=${CLIENT_PROFILE}
REGION=${CLIENT_REGION}

client_setup
#client_destroy

exit 0


