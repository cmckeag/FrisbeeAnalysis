model.points = function(data) {
  # Creates the glm object, using all the data
  glm(Scored ~ ., family = binomial(link = "logit"), data = data)
}

accuracy.points = function(data) {
  data = data[sample(nrow(data)),]
  sets = cut(seq(1, nrow(data)), breaks = 10, labels = FALSE)
  accs = rep(0, 10)
  
  for (i in 1:10) {
    testindex = which(sets == i)
    testset = data[testindex,]
    model = model.points(data[-testindex,])
    predictions = round(predict(model, newdata = testset, type = "response"))
    accs[i] = mean(predictions == testset[,"Scored"])
  }
  return(mean(accs))
}

predict.points = function(data, inputs) {
  inputs = as.logical(inputs)
  if (length(inputs) != ncol(data) - 1) {
    stop("Incorrect input format.")
  }
  if (sum(inputs) != 7) {
    warning("You should specify 7 players.")
  }
  model = model.points(data)
  newdata = data.frame(rbind(inputs))
  colnames(newdata) = colnames(data)[-1]
  rownames(newdata) = c()
  as.numeric(predict(model, newdata = newdata, type = "response"))
}