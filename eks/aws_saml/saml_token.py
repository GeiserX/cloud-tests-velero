#!/usr/bin/env /usr/local/bin/python

import os
import sys

import boto3
import boto.sts

import requests
import json

import re
import base64
import getpass
import ConfigParser
import xml.etree.ElementTree as ET

from datetime import datetime, timedelta

from pathlib import Path
from bs4 import BeautifulSoup
from os.path import expanduser
from urlparse import urlparse, urlunparse


### Variables

# Region: The AWS region to use
region = 'eu-central-1'

# Accountserver: Where to get the accountlist JSON from
accountserver = 'https://accounts.aws.de.clara.net/saml/'

# Identity Provider URL: Where to find the SSO Server
idpentryurl = 'https://sso.mgt.de.clara.net/adfs/ls/idpinitiatedsignon?logintorp=urn:amazon:webservices'


### Credentials
USER = sys.argv[1]
username = raw_input('Username: [' + USER +'] ')

if username == '':

    username = USER+ '@mgt.de.clara.net'

print 'Using: ' + username
password = getpass.getpass()
print('')


### SAML

# Initiate session handler
session = requests.Session()

# Programmatically get the SAML assertion
formresponse = session.get(idpentryurl, verify=True)

# Capture the idpauthformsubmiturl (the final URL after all the 302s)
idpauthformsubmiturl = formresponse.url

# Parse the response and extract all the necessary values in order to build a dictionary of all of the form values the IdP expects
formsoup = BeautifulSoup(formresponse.text.decode('utf8'),"lxml")
payload = {}

for inputtag in formsoup.find_all(re.compile('(INPUT|input)')):

    name = inputtag.get('name','')
    value = inputtag.get('value','')

    if "user" in name.lower():

        # Input username
        payload[name] = username

    elif "pass" in name.lower():

        # Input password
        payload[name] = password

# Some IdPs don't explicitly set a form action, but if one is set we should build the idpauthformsubmiturl by combining the scheme and hostname from the entry url with the form action target
# If the action tag doesn't exist, we just stick with the idpauthformsubmiturl above
for inputtag in formsoup.find_all(re.compile('(FORM|form)')):

    action = inputtag.get('action')
    loginid = inputtag.get('id')

    if (action and loginid == "loginForm"):

        parsedurl = urlparse(idpentryurl)
        idpauthformsubmiturl = parsedurl.scheme + "://" + parsedurl.netloc + action

# Submit the Login Form
response = session.post(idpauthformsubmiturl, data=payload, verify=True)

# Overwrite and delete the credential variables, just for safety
username = '##############################################'
password = '##############################################'
del username
del password

# Decode the response and extract the SAML assertion
soup = BeautifulSoup(response.text.decode('utf8'),"lxml")
assertion = ''

# Look for the SAMLResponse attribute of the input tag (determined by analyzing the debug print lines above)
for inputtag in soup.find_all('input'):

    if(inputtag.get('name') == 'SAMLResponse'):

        assertion = inputtag.get('value')

# Basic error handling
if (assertion == ''):

    for divtag in soup.find_all('div'):

        if(divtag.get('id') == 'error'):

            print('ERROR: Please check your username or password!')
	    print('')
            sys.exit(0)

    print ('ERROR: Response did not contain a valid SAML assertion!')
    sys.exit(0)

# Parse the returned assertion and extract the authorized roles
awsroles = []
root = ET.fromstring(base64.b64decode(assertion))

for saml2attribute in root.iter('{urn:oasis:names:tc:SAML:2.0:assertion}Attribute'):

    if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/Role'):

        for saml2attributevalue in saml2attribute.iter('{urn:oasis:names:tc:SAML:2.0:assertion}AttributeValue'):

            if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/Role'):

                awsroles.append(saml2attributevalue.text)

# Note the format of the attribute value should be role_arn,principal_arn but lots of blogs list it as principal_arn,role_arn so let's reverse them if needed
for awsrole in awsroles:

    chunks = awsrole.split(',')

    if 'saml-provider' in chunks[0]:

        newawsrole = chunks[1] + ',' + chunks[0]
        index = awsroles.index(awsrole)
        awsroles.insert(index, newawsrole)
        awsroles.remove(awsrole)


### Account List

# Get the account list (id /name mapping)
accountlist = requests.get(accountserver)
lookup = accountlist.json()

# If I have more than one role, ask the user which one they want, otherwise just proceed
if len(awsroles) > 1:

    i = 0
    space = ' '
    print('Please choose the role you would like to assume:\n')

    for awsrole in awsroles:

        role = awsrole.split(',')[0]

        if (i > 9):
            space = ''

        print('[' + space + str(i) + ']: ' + lookup[awsrole.split(':')[4]] + ' (' + str(awsrole.split(':')[4]) + '), ' + role.split('/')[1])
        i += 1

    print('')
    print('Selection: '),
    selectedroleindex = raw_input()

    # Basic sanity check of input
    if int(selectedroleindex) > (len(awsroles) - 1):

        print ('You selected an invalid role index, please try again')
        sys.exit(0)

    role_arn = awsroles[int(selectedroleindex)].split(',')[0]
    principal_arn = awsroles[int(selectedroleindex)].split(',')[1]

else:

    role_arn = awsroles[0].split(',')[0]
    principal_arn = awsroles[0].split(',')[1]

role = role_arn.split('/')[1]
account = lookup[role_arn.split(':')[4]]

print('')

# Ask user for how long the token should be valid
validity = raw_input('Token Validity in Hours [1]: ')

if validity == '':

    validity = 1

validity = int(validity) * 3600

# Use the assertion to get an AWS STS token using Assume Role with SAML
conn = boto.sts.connect_to_region(region)
token = conn.assume_role_with_saml(role_arn, principal_arn, assertion, duration_seconds=validity)


### Write the AWS STS token into the AWS credential file

filename = '/home/drumsergio/.aws/credentials'

# Read in the existing config file
config = ConfigParser.RawConfigParser()
config.read(filename)

# Put the credentials into a saml specific section instead of clobbering the default credentials
if not config.has_section('default'):
    config.add_section('default')

config.set('default', 'aws_access_key_id', token.credentials.access_key)
config.set('default', 'aws_secret_access_key', token.credentials.secret_key)
config.set('default', 'aws_session_token', token.credentials.session_token)

# Write the updated config file
with open(filename, 'w+') as configfile:
    config.write(configfile)

print('')


### Print Summary

print('Account: ' + account)
print('Role: ' + role + '\n')

expiration = token.credentials.expiration
expiry = datetime.strptime(expiration, '%Y-%m-%dT%H:%M:%SZ') + timedelta(hours=1)

print('Expiry: ' + str(expiry) + '\n')
