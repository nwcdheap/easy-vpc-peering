#!/bin/bash


FILES=""

# AWS China
china_test() {
	PROFILE=chinakb
	BUCKET=nwcdlabs
	REGION=cn-northwest-1

	for F in $FILES; do
		[ -f $F ] || continue

		KEY="templates/easy-vpc-peering/$F"
		aws --profile $PROFILE s3 cp $F s3://$BUCKET/$KEY
		aws --profile $PROFILE s3api put-object-acl --bucket $BUCKET --key $KEY --grant-read 'uri="http://acs.amazonaws.com/groups/global/AllUsers"'

		echo "Upload done: https://s3.$REGION.amazonaws.com.cn/$BUCKET/$KEY"
	done
}



# AWS Global
global_test() {
	PROFILE=global_admin
	BUCKET=leopublic
	REGION=ap-southeast-1

	for F in $FILES; do
		[ -f $F ] || continue

		KEY="templates/easy-vpc-peering/$F"
		aws --profile $PROFILE s3 cp $F s3://$BUCKET/$KEY
		aws --profile $PROFILE s3api put-object-acl --bucket $BUCKET --key $KEY --grant-read 'uri="http://acs.amazonaws.com/groups/global/AllUsers"'

		echo "Upload done: https://s3-$REGION.amazonaws.com/$BUCKET/$KEY"
	done
}



# 
#FILES="EasyVPN_Server.template EasyVPN_Server.yaml EasyVPN_Server_Setup.sh EasyVPN_Client.template EasyVPN_Client.yaml EasyVPN_Client_Setup.sh"
#FILES="EasyVPN_Server.template EasyVPN_Server.yaml EasyVPN_Server_Setup.sh"
#global_test

FILES="EasyVPN_Server.yaml EasyVPN_Server_Setup.sh EasyVPN_Client.yaml EasyVPN_Client_Setup.sh"
china_test

exit 0
