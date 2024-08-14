#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for the username
echo "Enter your username:"
read USERNAME

# Check if the username exists in the database
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

# If the user does not exist, create a new user
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # If the user exists, extract their information
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Initialize guess count
GUESS_COUNT=0

# Start the guessing loop
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # Increment the guess count
  ((GUESS_COUNT++))

  # Check if the guess is a valid integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  # Compare the guess to the secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    # Update the database with the new game information
    if [[ -z $USER_INFO ]]; then
      # Update the new user record
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=1, best_game=$GUESS_COUNT WHERE username='$USERNAME'")
    else
      # Update the existing user record
      if [[ $GUESS_COUNT -lt $BEST_GAME ]]; then
        BEST_GAME=$GUESS_COUNT
      fi
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played + 1, best_game=$BEST_GAME WHERE username='$USERNAME'")
    fi
    break
  fi
done