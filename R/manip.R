# See README.md for documentation

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

extract.data = function(filename) {
  if (grepl(".csv",filename)) {
    filename = gsub(".csv","",filename)
  }
  raw = get.raw(filename)
  
  raw2 = ignore.cessations(raw)
  
  passes = count.passes(raw2)
  possessions = count.possessions(raw2)
  
  raw3 = raw2[raw2$Action == "Goal",]
  
  outcome = (raw3$Event.Type == "Offense")
  
  players = get.all.players(raw3)
  desired = c("Player.0","Player.1","Player.2","Player.3","Player.4",
              "Player.5","Player.6","Player.7")
  
  new.dat = data.frame(Scored = outcome,
                       Duration = raw3$Point.Elapsed.Seconds,
                       Passes = passes,
                       Possessions = possessions,
                       Line = raw3$Line,
                       t(as.matrix(apply(raw3[,desired],1,function(x) players %in% x))))
  colnames(new.dat) = c("Scored","Duration","Passes","Possessions","Line",players)
  
  write.csv(new.dat, file = paste("out/", filename, ".csv", sep = ""), row.names=FALSE)
  return(new.dat)
}

ignore.cessations = function(raw) {
  # Should only affect AUDL teams.
  cess.index = which(raw$Event.Type == "Cessation")
  if (length(cess.index) == 0) {
    return(raw)
  }
  goal.index = which(raw$Action == "Goal")
  ignore.index = numeric()
  if (length(cess.index) > 0) {
    for (i in cess.index) {
      last = goal.index[max(which(goal.index < i))]
      ignore.index = c(ignore.index, (last+1):i)
    }
  }
  raw[-ignore.index,]
}

count.passes = function(raw) {
  goal.index = which(raw$Action == "Goal")
  groups = cut(seq(1,nrow(raw)), breaks = c(0,goal.index), labels = FALSE)
  pass.actions = raw$Action == "Catch" | 
                (raw$Action == "Goal" & raw$Event.Type == "Offense")
  as.vector(aggregate(pass.actions, by = list(groups), FUN = sum)$x)
}

count.possessions = function(raw) {
  goal.index = which(raw$Action == "Goal")
  groups = cut(seq(1,nrow(raw)), breaks = c(0,goal.index), labels = FALSE)
  poss.actions = raw$Action == "Drop" | 
                (raw$Action == "Throwaway" & raw$Event.Type == "Offense") | 
                (raw$Action == "Goal" & raw$Event.Type == "Offense")
  as.vector(aggregate(poss.actions, by = list(groups), FUN = sum)$x)
}