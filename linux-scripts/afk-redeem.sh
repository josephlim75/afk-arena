#!/bin/bash

if [[ ! -f ./afk.uid ]]; then
  read -p "First time AFK UID Registration: " AFK_UID
  echo $AFK_UID > ./afk.uid
  echo "Registration completed."
else
  export AFK_UID="$(cat ./afk.uid)"
fi

# Send verification code
curl -s --header "Content-Type: application/json;charset=UTF-8" \
  --request POST \
  --data "{\"game\": \"afk\", \"sender\": \"sender\", \"template\": \"You are currently logging in to an external payment portal. You verification code is: {{code}}. This verification code will expire in 10 minutes. Please use this code to log in. Do not send this code to anyone else. Sender: AFK Arena Team\", \"title\": \"Verification Code\", \"uid\": $AFK_UID}" \
  http://cdkey.lilith.com/api/send-mail

echo ""

read -p "Enter your verification code: " AFK_VERIFICATION_CODE
read -p "Enter your redemption code: " AFK_REDEMPTION_CODE

# Remove cookie file
rm -f ./afk_auth_cookie

# Verify code
curl --header "Content-Type: application/json;charset=UTF-8" \
  -c ${PWD}/afk_auth_cookie \
  --request POST \
  --data "{\"uid\": $AFK_UID, \"game\": \"afk\", \"code\": \"$AFK_VERIFICATION_CODE\"}" \
  http://cdkey.lilith.com/api/verify-code

echo ""
sleep 2

# Redeem code
curl --header "Content-Type: application/json;charset=UTF-8" \
  -b ${PWD}/afk_auth_cookie \
  --request POST \
  --data "{\"type\": \"cdkey_web\", \"game\": \"afk\", \"uid\": $AFK_UID, \"cdkey\": \"$AFK_REDEMPTION_CODE\"}" \
  http://cdkey.lilith.com/api/cd-key/consume
