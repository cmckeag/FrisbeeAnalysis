# FrisbeeAnalysis

## Introduction
This is a project in manipulating data collected in the sport of ultimate frisbee and using it to predict future outcomes.

Data is available on www.ultianalytics.com. Ultinalaytics collects data for every action that happens during a game. For AUDL teams, this is typically ~5000 rows.

The objective of this project was to take raw from ultianalytics, and extract only the points scored and the players on the field when the point was scored. Then, you could use this data to create a model that would predict the likelihood of a given set of players scoring.

## Requirements
The project uses only the base packages available in R.

## manip.R
manip.R contains functions for extracting raw data and converting it into points data.

#### get.raw(filename)
Takes as input the filename (case insensitive), and returns a dataframe containing the entire raw dataset.

File must be located in the /data/ folder.

#### get.points(filename)
Converts raw data into points data. Each row of the resulting dataframe corresponds to one point. The dataframe contains 1 logical variable for every player on the team, which indicates if that player was on the field at the end of that point. The first variable in the dataframe, "Scored," is a logical variable that indicates the outcome of that point: True if this team scored, False if the other team scored.

The function then writes the resulting points dataframe into a csv file located in the /out/ folder.

For an AUDL team, this dataframe typically has between 500-1000 rows.

#### get.dur(filename)
Converts raw data into duration data. Each row corresponds to a point played. The response variable is the duration in seconds of that point. The other variables are indicator variables corresponding to which players were on the line for that point.

The function then writes the resulting dataframe into a csv file located in the /out/ folder.

#### get.all.players(raw)
Helper function for `get.points()`. Takes as input the raw data, then returns a vector of strings corresponding to every player on the team, in alphabetical order.
An equivalent list can be extracted from points data by doing `colnames(points.data)[-1]`.

## analyze.R
analyze.R contains functions for performing regression on points data, and returning useful information from that regression.
All functions take points data as input, not raw data.

#### model.points(point.data)
Creates a logistic regression model object using all the given data. Logistic regression makes the most sense given the predictors and response.

#### model.dur(dur.data)
Creates a standard least squares regression object using the duration data.

#### accuracy.points(point.data)
Uses 10-fold validation to assess the accuracy of the logistic model.
Depending on the amount of points data available, accuracy typically ranges from 0.5 to 0.8.
`predict()` sometimes gives warnings for teams with a large number of players and small number of points, so the warning is suppressed.

#### predict.point(point.data, line)
Given the previous points data, and a line of 7 players, returns the probability of that line scoring.
`line` must be in the correct format: a logical vector with each entry corresponding to a player on the team, in alphabetical order. True entries mean the player is on the line, False entries mean the player is not on the line. The length of the vector must be the same as the total number of players on the team. You can specify any number of players on the line, but it would make the most sense to specify 7 players.
Use the `generate.line()` function to generate a line in the correct format.

#### predict.dur(dur.data, line)
Given the previous duration data, and a line of 7 players, predict the duration of this point.

#### player.ranking(point.data)
Since the model is made via logistic regression of a boolean response versus boolean indicator variables, then the coefficients rougly and naively represent each players' "contribution" to the team. Returns a list of players on the team, in decreasing order according to their coefficient value.

The magnitude and sign of the value have little meaning itself, only the order of players provides any useful insight.
For high-level AUDL teams, this typically results in O-line players at the top of the list and D-line players at the bottom.
For lower level teams, this list pretty accurately sorts "good" players at the top and "bad" players at the bottom.

#### generate.line(point.data, playerlist = NULL)
Takes the point data as input. Prompts the user 7 times to select players from the team. Returns the corresponding locigal vector `line` for use in `predict.point(point.data, line)`.
Alternatively, provide a list of strings `playerlist` and `generate.line()` will attempt to create the corresponding logical vector. The names in `playerlist` must be exact (but case insensitive).

## Conclusion
Ultimately, trying to predict the outcome of a point using only the players on the field is a pretty naive way of doing things. There are certainly more factors at play that can be used to determine the response, although the accuracy of this method isn't terrible. `predict.point()` acts as a neat proof-of-concept that could be built upon further. However, due to the random nature of sports, one would not expect to be able to reliably and consistently predict the outcome of a point before it starts.

Despite this, `player.ranking()` provides some interesting insight into the team in question, especially for lower level teams.

## Future Additions
The data available on www.ultianalytics.com goes far beyond just points scored. There are certainly other problems to consider, and other angles to approach this problem from.
 * Include further variables to predict points beyond players on the field (for example: duration of point, number of points played already, number of turnovers in the point, etc)
 * Try another model for prediction. Logistic regression made the most sense to me, but other classification methods may work better. (However I would not expect kNN to work for this problem as it currently is, due to all the predictors being indicator variables)
 * Consider consolidating all relevant data per point into one singular dataframe, and then we can work with that dataframe in all the `analyze.R` methods, instead of having separate functions require specific dataframe types.