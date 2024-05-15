#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNERGOALS OPPONENTGOALS
do
  if [[ $WINNER != winner ]]
  then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    if [[ -z $TEAM_ID ]]
    then
      echo "Vamos a insertar $WINNER"
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo "Insertado $WINNER con ID $TEAM_ID"
    fi
  fi
  if [[ $OPPONENT != opponent ]]
  then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    if [[ -z $TEAM_ID ]]
    then
      echo "Vamos a insertar $OPPONENT"
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo "Insertado $OPPONENT con ID $TEAM_ID"
    fi
  fi
  if [[ $YEAR != year ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNERGOALS, $OPPONENTGOALS)")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID AND winner_goals = $WINNERGOALS AND opponent_goals = $OPPONENTGOALS")
    echo "$GAME_ID Año $YEAR Ronda $ROUND Resultado: ($WINNER_ID) $WINNER $WINNERGOALS - $OPPONENTGOALS $OPPONENT ($OPPONENT_ID)"
  fi
done
