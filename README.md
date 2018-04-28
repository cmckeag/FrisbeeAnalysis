# FrisbeeAnalysis

## Introduction
This is a project in manipulating data collected in the sport of ultimate frisbee and using it to predict future outcomes.

Data is available on www.ultianalytics.com. Ultinalaytics collects data for every action that happens during a game. For AUDL teams, this is typically ~5000 rows.

The objective of this project was to take raw data from ultianalytics, and extract only the points scored and the players on the field when the point was scored. Then, you could use this data to create a model that would predict the likelihood of a given set of players scoring.

## Requirements
The project uses only the base packages available in R.

## manip.R
manip.R contains functions for extracting raw data and converting it into per-point data.

#### get.raw(filename)
Takes as input the filename (case insensitive), and returns a dataframe containing the entire raw dataset.

File must be located in the /data/ folder.

#### extract.data(filename)
All purpose function for taking raw data from ultianalytics, and converts it into a dataframe where each row represents a point played.
The variables are:
`Scored` is a boolean that represents the outcome of the point. TRUE for scored, FALSE for didn't score
`Duration` is the duration fo the point, in seconds. This data tends to not be accurate, depending on the team's stat-keeping practices.
`Passes` is the total number of passes completed in the point.
`Possessions` is the number of offensive possessions the team had on that point.
`Line` is whether the team started on Offense or Defense for that point.
The rest of the variables are indicator variables, with one variable for each player on the team. TRUE indicates that player was on for that point, FALSE indicates that they were not. This format makes it very easy to make models as a function of the players on the field.

If adding additional columns to the returned dataframe, note that the functions in `analyze.R` are hard coded to select player variables by ignoring the first 5 columns of the dataframe. If adding more columns, those functions must be adjusted to ignore the extra columns.

#### get.all.players(raw)
Helper function for `get.points()`. Takes as input the raw data, then returns a vector of strings corresponding to every player on the team, in alphabetical order.
An equivalent list can be extracted from points data by doing `colnames(points.data)[-1]`.

## analyze.R
analyze.R contains functions for performing regression on the data, and returning useful information from that regression.
All functions take `extract.data()` dataframes as input, not raw data.

`extract.data()` puts the data in a very flexible format. Although there are some simple regression methods here, there are a lot more ways to generate models from the data, and a lot more response variables to try to predict. These functions are certainly not the limit of what can be done with this data.

Note that these functions are hard coded to ignore the first 5 columns of the data frame when selecting the player variables. Therefore, if the `extract.data()` function is modified to include more or less columns, these functions must be adjusted to account for that.

#### model.points(dat)
Creates a logistic regression model object of `Scored` vs. players. Logistic regression makes the most sense given the predictors and response.
Could be expanded to include other variables.

#### model.dur(dat)
Creates a standard least squares regression object of `Scored` vs. players.
Could be expanded to include other variables (but the relationship between the other variables and point duration is already pretty obvious).

#### accuracy.points(dat)
Since `Scored` is boolean, we have an easy metric for checking the accuracy of our logistic points model.
Uses 10-fold validation to assess the accuracy of the logistic model.
Depending on the amount of points data available, accuracy typically ranges from 0.5 to 0.8.
`predict()` sometimes gives warnings for teams with a large number of players and small number of points, so the warning is suppressed.

#### predict.point(dat, line)
Generates a logistic regression object using `model.points(dat)`. Uses the `predict` function, with new data being a line of 7 players, to return the probability of that line scoring.
`line` must be in the correct format: a logical vector with each entry corresponding to a player on the team, in alphabetical order. TRUE entries mean the player is on the line, FALSE entries mean the player is not on the line. The length of the vector must be the same as the total number of players on the team. You can specify any number of players on the line, but it would make the most sense to specify 7 players.
Use the `generate.line()` function to generate a line in the correct format.
If modifying `model.points(dat)` to include more variables, then the `line` input must be modified to include those variables.

#### predict.dur(dat, line)
Given the previous duration data, and a line of 7 players, predict the duration of this point.

#### player.ranking(dat)
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
