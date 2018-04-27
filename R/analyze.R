model.points = function(point.data) {
  # Creates a logistic model object, using all the data
  glm(Scored ~ ., family = binomial(link = "logit"), data = point.data)
}

model.dur = function(dur.data) {
  # Consider adding outlier detection, especially for low values.
  lm(Duration ~ ., data = dur.data)
  # Is there a way to check "accuracy" in terms of a number between 0-1?
  # Response is numeric so we can only get MSE/absolute error, not a percentage.
}

accuracy.points = function(point.data) {
  # Uses 10-fold validation to check the accuracy of the model
  point.data = point.data[sample(nrow(point.data)),]
  sets = cut(seq(1, nrow(point.data)), breaks = 10, labels = FALSE)
  accs = rep(0, 10)
  
  for (i in 1:10) {
    testindex = which(sets == i)
    testset = point.data[testindex,]
    model = model.points(point.data[-testindex,])
    predictions = round(suppressWarnings(predict(model, newdata = testset, type = "response")))
    accs[i] = mean(predictions == testset[,"Scored"])
  }
  return(mean(accs))
}

predict.point = function(point.data, line) {
  # Predict the chance of a line scoring.
  line = as.logical(line)
  if (length(line) != ncol(point.data) - 1) {
    stop("Incorrect input format.")
  }
  if (sum(line) != 7) {
    warning("You should specify 7 players.")
  }
  model = model.points(point.data)
  newdata = data.frame(rbind(line))
  colnames(newdata) = colnames(point.data)[-1]
  rownames(newdata) = c()
  as.numeric(predict(model, newdata = newdata, type = "response"))
}

predict.dur = function(dur.data, line) {
  # Predict the duration of this point in seconds
  line = as.logical(line)
  if (length(line) != ncol(dur.data) - 1) {
    stop("Incorrect input format.")
  }
  if (sum(line) != 7) {
    warning("You should specify 7 players.")
  }
  model = model.dur(dur.data)
  newdata = data.frame(rbind(line))
  colnames(newdata) = colnames(dur.data)[-1]
  rownames(newdata) = c()
  as.numeric(predict(model, newdata = newdata))
}

player.ranking = function(point.data) {
  model = model.points(point.data)
  players = colnames(point.data)[-1]
  res = data.frame(Player = players, Value = as.numeric(coef(model)[-1]), stringsAsFactors = FALSE)
  res = as.data.frame(res[order(res$Value, decreasing = TRUE),])
  rownames(res) = NULL
  return(res)
}

generate.line = function(point.data, playerlist = NULL) {
  players = colnames(point.data)[-1]
  if (length(players) < 7) {
    stop("Not enough players on this team.")
  }

  if (!is.null(playerlist)) {
    if (!is.character(playerlist)) {
      stop("The list you provided is not of type character")
    }
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