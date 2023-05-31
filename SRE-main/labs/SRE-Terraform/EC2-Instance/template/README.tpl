###############################################################################
Your EC2 instance can be accessed via ssh using the following:

Username: ubuntu
ssh_key: ${ KEY_NAME }.pem
Public IP: ${ PUBLIC_IP_ADDRESS }
Public DNS Name: ${ DNS_NAME }

To access your instance, please run either of the following commands on your jumphost:

ssh -i ${ KEY_NAME }.pem ubuntu@${ DNS_NAME }

or

ssh -i ${ KEY_NAME }.pem ubuntu@${ PUBLIC_IP_ADDRESS }

Please note that if your instance reboots, the public IP address may change. Please re-run terraform via "terraform apply" to recreate
this file with updated information.
################################################################################



