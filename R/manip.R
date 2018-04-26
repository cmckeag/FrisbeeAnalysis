# Contains functions for manipulating the original datasets from
# ultianalytics.

get.raw = function(filename) {
  # filename should be located in the /data/ folder
  # returns a dataframe containing the outcome of every point
  # (True for scored, False for did not score)
  # and which players were on the field at the conclusion of the point
  
  if (grepl(".csv",filename)) {
    filename = gsub(".csv","",filename)
  }
  if (!file.exists(paste("data/", filename, ".csv", sep = ""))) {
    stop("File does not exist")
  }
  read.csv(paste("data/",filename,".csv", sep = ""), stringsAsFactors = FALSE)
}

get.points = function(filename) {
  if (grepl(".csv",filename)) {
    filename = gsub(".csv","",filename)
  }
  
  raw = get.raw(filename)
  desired = c("Event.Type",
              "Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  points.data = raw[raw$Action == "Goal",desired]
  players = get.all.players(raw)
  new.dat = data.frame(Scored = points.data[,1], t(as.matrix(apply(points.data[,desired[-1]],1,function(x) players %in% x))))
  colnames(new.dat) = c("Scored",players)
  new.dat[,1] = as.logical(as.numeric(factor(new.dat[,1], levels = c("Defense", "Offense")))-1)
  
  write.csv(new.dat, file = paste("out/", filename, "_points.csv", sep = ""), row.names=FALSE)
  return(new.dat)
}

get.all.players = function(raw) {
  # Returns vector of the name of every player on the team
  # in alphabetical order
  desired = c("Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  players = unique(unlist(raw[,desired]))
  players = players[!(players %in% c("","Anonymous"))]
  players = players[!is.na(players)]
  players = players[order(players)]
  return(players)
}