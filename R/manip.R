# Contains functions for manipulated the original datasets from
# ultianalytics.

get.points = function(raw) {
  desired = c("Event.Type",
              "Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  working.data = raw[raw$Action == "Goal",desired]
  players = unique(unlist(working.data[,desired[-1]]))
  players = as.character(players[!is.na(players)])
  players = players[order(players)]
  new.dat = data.frame(matrix(vector(), nrow = 0, ncol = 1 + length(players)))
  colnames(new.dat) = c("Scored",players)
  
}