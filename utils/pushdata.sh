#!/bin/bash

#
# Sample curl REST call to push contact data to CiviCRM
# Required:
#   CIVI_URL: URL for CiviCRM REST calls
#   CIVI_SITEKEY: configured in sites/default/civicrm.settings.php
#   CIVI_APIKEY: configured on contact record for user "API User", ID#205

CIVIURL=http://13.59.66.198/sites/all/modules/civicrm/extern/rest.php
CIVI_SITEKEY=74ef995307b41fbcc2bbcd01ae03c0b1
CIVI_APIKEY=4af4991708cbb50f4283a106315d7ec6

# Contact information
FIRST_NAME="John"
LAST_NAME="Doe"
EMAIL="jdoe@example.com"

curl --insecure --request POST $CIVIURL \
  --data-urlencode "api_key=$CIVI_APIKEY" \
  --data-urlencode "key=$CIVI_SITEKEY" \
  --data-urlencode "json=1" \
  --data-urlencode "version=3" \
  --data-urlencode "entity=Contact" \
  --data-urlencode "action=Create" \
  --data-urlencode "json={\"contact_type\": \"Individual\",
    \"first_name\": \"$FIRST_NAME\",
    \"last_name\": \"$LAST_NAME\",
    \"api.Email.create\": {\"location_type_id\": \"Main\", \"email\": \"$EMAIL\"}}"
