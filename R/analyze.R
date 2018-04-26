log.model.points = function(data) {
  # Creates a logistic model object, using all the data
  glm(Scored ~ ., family = binomial(link = "logit"), data = data)
}

accuracy.points = function(data) {
  # Uses 10-fold validation to check the accuracy of the model
  data = data[sample(nrow(data)),]
  sets = cut(seq(1, nrow(data)), breaks = 10, labels = FALSE)
  accs = rep(0, 10)
  
  for (i in 1:10) {
    testindex = which(sets == i)
    testset = data[testindex,]
    model = log.model.points(data[-testindex,])
    predictions = round(predict(model, newdata = testset, type = "response"))
    accs[i] = mean(predictions == testset[,"Scored"])
  }
  return(mean(accs))
}

predict.points = function(data, line) {
  # Predict the chance of a line scoring.
  line = as.logical(line)
  if (length(line) != ncol(data) - 1) {
    stop("Incorrect input format.")
  }
  if (sum(line) != 7) {
    warning("You should specify 7 players.")
  }
  model = log.model.points(data)
  newdata = data.frame(rbind(line))
  colnames(newdata) = colnames(data)[-1]
  rownames(newdata) = c()
  as.numeric(predict(model, newdata = newdata, type = "response"))
}

generate.line = function(filename, playerlist = NULL) {
  source("R/manip.R")
  players = get.all.players(get.raw(filename))
  if (length(players) < 7) {
    stop("Not enough players on this team.")
  }
  
  if (!is.null(playerlist)) {
    if (length(playerlist) != 7) {
      warning("You should provide a list of 7 players")
    }
    res = tolower(players) %in% tolower(playerlist)
    if (length(playerlist) != sum(res)) {
      excluded = paste(playerlist[which(!(tolower(playerlist) %in% tolower(players)))], collapse = ",")
      warning(paste("The following players are not on the team: ", excluded))
    }
    return(res)
  }
  
  print(players)
  input.list = character()
  while (TRUE) {
    input = readline(paste("Select a player (", length(input.list), "/7):"))
    if (tolower(input) %in% tolower(players) & !(tolower(input) %in% tolower(input.list))) {
      input.list[length(input.list)+1] = players[which(tolower(players) %in% tolower(input))]
      if (length(input.list) == 7) {
        break
      }
    } else if (input == "") {
      print("End function.")
      return()
    } else {
      print("Invalid player")
    }
  }
  print("Complete")
  return(players %in% input.list)
}