#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  # Get Team Name
  if [[ $OPPONENT != 'opponent' || $WINNER != 'winner' ]]
  then
    NAME_OPPONENT=$($PSQL "select name from teams where name='$OPPONENT'")
    # If not found
    if [[ -z $NAME_OPPONENT ]]
    then
      # Insert team Name
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo $INSERT_TEAM_RESULT
    fi
    
    NAME_WINNER=$($PSQL "select name from teams where name='$WINNER'")
    if [[ -z $NAME_WINNER ]]
    then
      # Insert team Name
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo $INSERT_TEAM_RESULT
    fi

    # insert their games
    #select oponent id, select winer_id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    # insert into games(year, round, winner_goals, opponent_goals
    INSERT_GEAMS_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS, $OPPONENT_GOALS)")
    echo $INSERT_GEAMS_RESULT

  fi
  # 
 
  # TEAM_NAME=
  
#  echo "--------" $TEAM_NAME
#  if [[ $OPPONENT != "opponent" ]]
#  then
    # get team name

    # if not found
#    if [[ -z $TEAM_NAME ]]
#    then
      #TEAM_NAME=null
#      echo "--------" $TEAM_NAME
#    fi

    # insert into 

 #   if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
 #   then
 #     echo inserted into results,  $TEAM_NAME
 #   fi
#  fi

done