#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to the salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to The Epic Salon. How can I help you?" 
  echo -e "1) Cut\n2) Color\n3) Perm\n4) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU $SERVICE_ID_SELECTED ;;
    2) SERVICE_MENU $SERVICE_ID_SELECTED ;;
    3) SERVICE_MENU $SERVICE_ID_SELECTED ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

SERVICE_MENU() {
  if [[ $1 ]]
  then
    SERVICE_ID=$1
    SERVICE=$(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID") | sed -E 's/^ *| *$//g')
    echo -e "\nYou have selected the following service: $SERVICE."

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if not found
    if [[ -z $CUSTOMER_ID ]]
    then
      # add customer
      echo -e "\nI could not find a record for that phone number. What's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo -e "It's nice to meet you, $CUSTOMER_NAME"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID") | sed -E 's/^ *| *$//g')
      echo -e "Welcome back to our salon, $CUSTOMER_NAME"
    fi

    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME. Your appointment has been confirmed."
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
