#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ SALON APPOINTMENT SCHEDULER ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\nPlease choose an appointment from the menu:\nTo exit the menu please select 0!\n"
  # List of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    0) EXIT ;;
    [1-9]|10) BOOK_APPOINTMENT ;;
    *) MAIN_MENU "Sorry, there is no such service. Please select an existing one." ;;
  esac
}

BOOK_APPOINTMENT() {
  # Get phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # If new customer, prompt for name and add to customers table
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nNew customer, please enter your name:"
    read CUSTOMER_NAME
    
    # Insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    echo -e "\nWelcome back, $CUSTOMER_NAME!"
  fi

  # Retrieve the customer_id for appointments
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Prompt for appointment time
  echo -e "\nPlease enter your preferred appointment time:"
  read SERVICE_TIME

  # Insert appointment into appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm appointment
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

# Start script
MAIN_MENU
