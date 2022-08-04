#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICES_CHOICE(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$LIST_SERVICES" | sed 's/|/ /g' | while read SERVICE_ID NAME_SERVICE
  do
    echo "$SERVICE_ID) $NAME_SERVICE"
  done
  echo "0) Exit"
  read SERVICE_ID_SELECTED
  CHOICE_SERVICE_EXISTENCE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then
   exit
  else
    if [[ -z $CHOICE_SERVICE_EXISTENCE ]]
    then
      SERVICES_CHOICE "The selected service does not exist, select again:"
    else
      echo "What's your phone number?"
      read CUSTOMER_PHONE
      PHONE_NUMBER_EXISTENCE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $PHONE_NUMBER_EXISTENCE ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER_REGISTRATION=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      else
        CUSTOMER_NAME=$PHONE_NUMBER_EXISTENCE
      fi
      echo "What time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      APPOINTMENT_REGISTRATION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}
SERVICES_CHOICE