#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
if [[ $($PSQL "TRUNCATE TABLE games, teams") == "TRUNCATE TABLE" ]]
then
  echo All rows have been deleted.
fi
#Resets id value in DB to 1 however next is 2
if [[  $($PSQL "SELECT setval('games_game_id_seq', 1), setval('teams_team_id_seq', 1)") == "1|1" ]]
then
  echo IDs have been reset
fi

cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $WINNER != winner ]]
  then
    #Add every unique team (24 rows)
    if [[ -z $($PSQL "SELECT name FROM teams WHERE name='$WINNER'") ]]
    then
      if [[ $($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')") == "INSERT 0 1" ]]
      then
        echo Inserted new team: $WINNER
      fi
    fi
    if [[ -z $($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'") ]]
    then
      if [[ $($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')") == "INSERT 0 1" ]]
      then
        echo Inserted new team: $OPPONENT
      fi
    fi

    #Add all the game matches except top line (32 rows)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)") == "INSERT 0 1" ]]
    then
      echo New game inserted: $YEAR $ROUND between $WINNER and $OPPONENT. Final score $WINNER_GOALS:$OPPONENT_GOALS.
    fi

  fi

done


