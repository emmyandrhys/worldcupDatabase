#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WGOAL OGOAL
do
#skip header row
if [[ $YEAR != 'year' ]]
then
  #get winning team_id
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  #if winning team_id not found 
  if [[ -z $WINNER_ID ]]
  then
    #insert winning team_id
    INSERT_WINNER_NAME="$($PSQL "INSERT INTO teams(name)VALUES('$WINNER')")"
    if [[ $INSERT_WINNER_NAME == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $WINNER"
    fi
    #get new winning team_id
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  fi
  #get opponent team_id
  OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  #if not found
  if [[ -z $OPP_ID ]]
  then
    #insert opponent team_id
    INSERT_OPPONENT_NAME="$($PSQL "INSERT INTO teams(name)VALUES('$OPPONENT')")"
    if [[ $INSERT_OPPONENT_NAME == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $OPPONENT"
    fi    
    #get new opponent team_id
    OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  fi
  #insert match data
  INSERT_MATCH="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$WINNER_ID,$OPP_ID,$WGOAL,$OGOAL)")"
  if [[ $INSERT_MATCH == "INSERT 0 1" ]]
  then
    echo "Inserted Year: $YEAR, Round: $ROUND, Winner: $WINNER, Opponent: $OPPONENT, Score: $WGOAL to $OGOAL"
  fi 
fi
done
