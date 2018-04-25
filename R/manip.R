# Contains functions for manipulated the original datasets from
# ultianalytics.

read.data = function(filename) {
  # filename must be in "*.csv" format
  # file must located in the /data/ folder.
  # returned dataframe is strings only.
  # all functions assume data was obtained via this method.
  read.csv(paste("data/", filename, sep = ""), stringsAsFactors = FALSE)
}

get.points = function(raw) {
  # Returns dataframe containing every point played
  # including if the point was scored, and which members of the
  # team were playing when the point was scored
  desired = c("Event.Type",
              "Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  points.data = raw[raw$Action == "Goal",desired]
  players = get.all.players(raw)
  new.dat = data.frame(Scored = points.data[,1], t(as.matrix(apply(points.data[,desired[-1]],1,function(x) players %in% x))))
  colnames(new.dat) = c("Scored",players)
  new.dat[,1] = as.logical(as.numeric(factor(new.dat[,1], levels = c("Defense", "Offense")))-1)
  return(new.dat)
}

get.all.players = function(raw) {
  # Returns vector of the name of every player on the team
  # in alphabetical order
  desired = c("Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  players = unique(unlist(raw[,desired]))
  players = players[players != ""]
  players = players[order(players)]
  return(players)
}