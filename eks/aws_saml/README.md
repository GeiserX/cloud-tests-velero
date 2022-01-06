# NAME

aws_saml_token - A script to get a temporary SAML token for IAM roles in AWS accounts

# SYNOPSIS

Run this script to get a temporary token for AWS. You can choose which Account to use

# REQUIREMENTS
**AWS CLI has to be installed and configured locally by typing `aws configure` in a terminal and entering the default region `eu-central-1` before running the script!**

Minimum config (the two files are located in the .aws folder in your home directory, create them if they don't exist):
```
# cat .aws/config
[default]
region = eu-central-1
```
```
# cat .aws/credentials 
[default]
aws_access_key_id = xxx
aws_secret_access_key = xxx
aws_session_token = xxx
```
You can leave "xxx" as these lines get overwritten by the script anyway.

# INSTALLATION
1. Tap the `claranet/core` repository if not done yet:
  `brew tap claranet/core git@git.eu.clara.net:de-platforms/homebrew-core.git`
1. Install the wrapper:
  `brew install aws-saml-token`
1. Login to the Claranet Registry, so that *aws-saml-token* is able to pull the
   Docker image on the first run.
  `docker login registry.eu.clara.net`

# USAGE
Just run `aws-saml-token`

After entering your Management AD credentials, you can choose a role to assume from one of the AWS Accounts you have access to.

Default token validity is one hour. 
Depending on the account settings, you should be able to request up to 12 hours of token validity.

Once the credentials have been retrieved, they are use by your default profile, so you don't have to specify a special profile name when calling the AWS CLI or using terraform.

After the token has expired simply rerun the script.

# BACKEND

The Python script uses a backend service that provides a list of accountnames for all AWS accounts by number. This JSON is generated in realtime by a lambda function behind a private application loadbalancer within the claranet-de AWS account. As it only uses private IPs for security reasons (10.160.160.0/24), a VPN connection to the Claranet Office (192.168.0.0/22) is necessary to access them over the existing Direct Connect.

External accounts not part of the Claranet AWS Organization must be mapped (account id -> account name) manually in the following lambda function:
https://eu-central-1.console.aws.amazon.com/lambda/home?region=eu-central-1#/functions/listAccountsProd

For any questions regarding these backend services ask Max (maximilian.breig@de.clara.net).
