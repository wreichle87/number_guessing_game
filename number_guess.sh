#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#echo -e "\n~~~~~Number Guessing Game~~~~~\n"
MIN=1
MAX=1000
SECRET_NUMBER=$(($RANDOM%($MAX-$MIN+1)+$MIN))
USERNAME_PROMPT() {
  echo Enter your username:
  read USERNAME
  if [[ -z $USERNAME ]]
  then
    USERNAME_PROMPT
  fi
  if [[ "${#USERNAME}" -gt 22 ]]
  then
    echo -e "Your username must be less than 23 characters."
    USERNAME_PROMPT
  fi
}
USERNAME_PROMPT
CHECK_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
if [[ -z $CHECK_USERNAME ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');");
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID;")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
NUMBER_OF_GUESSES=0
#echo $RANDOM_NUM - random num
echo -e "Guess the secret number between 1 and 1000:"
GUESSES1() {
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    GUESSES1
  else 
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      ((NUMBER_OF_GUESSES++))
      GUESSES1
    else 
      if [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        #counter
        ((NUMBER_OF_GUESSES++))
        GUESSES1
      else
        ((NUMBER_OF_GUESSES++))
      fi
    fi
  fi
}
GUESSES1
GAMES_INSERT=$($PSQL "INSERT INTO games(user_id,random_num,number_of_guesses) VALUES($USER_ID,$SECRET_NUMBER,$NUMBER_OF_GUESSES);")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
