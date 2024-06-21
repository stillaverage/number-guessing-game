#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


GENERATE_SECRET_NUMBER() {
  # generate random number
  SECRET_NUMBER=$(($RANDOM%1000 + 1))
}

WELCOME_USER() {
  echo "Welcome, $USERNAME! It looks like this is your first time here."
}

WELCOME_BACK_USER() {
  echo $USER_INFO | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
}

GET_USER_INFO() {
  echo "Enter your username:"
  read USERNAME
  USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
  if [[ -z $USER_INFO ]]
  then
    WELCOME_USER
  else
    WELCOME_BACK_USER
  fi
}

GET_INPUT_GUESS() {
  if [[ $1 ]]
  then
    echo $1
  fi
  read INPUT_GUESS
  if [[ ! $INPUT_GUESS =~ ^[0-9]+$ ]]
  then
    GET_INPUT_GUESS "That is not an integer, guess again:"
  else
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    if [[ $INPUT_GUESS -gt $SECRET_NUMBER ]]
    then
      GET_INPUT_GUESS "It's lower than that, guess again:"
    elif [[ $INPUT_GUESS -lt $SECRET_NUMBER ]]
    then
      GET_INPUT_GUESS "It's higher than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}

UPDATE_USER_INFO() {
  if [[ -z $USER_INFO ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES);")
  else
    echo $USER_INFO | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME
    do
      UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME';")
      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
      fi
    done
  fi
}

MAIN() {
  GENERATE_SECRET_NUMBER
  GET_USER_INFO
  NUMBER_OF_GUESSES=0
  GET_INPUT_GUESS "Guess the secret number between 1 and 1000:"
  UPDATE_USER_INFO
}


MAIN
