# posthoc test function
posthoc_abtest <- function(data, method = "BH", alpha = 0.05, rounding = 10) { #data's row dimnames must be "segment"
  #initiate placeholder for storing each pair's p-values and dimnames-row
  raw_p_values = c()
  raw_lower_cis = c()
  raw_upper_cis = c()
  row_names = c()
  #indexer
  k = 1
  #chi square test each combination pair
  for(i in 1:(nrow(data)-1)) {
    for(j in 2:nrow(data)) {
      if(i<j) {
        proportion_test = prop.test(data[c(i,j),], alternative = "two.sided")
        raw_p_values[k] = proportion_test$p.value
        raw_lower_cis[k] = -proportion_test$conf.int[2] #reversed to show the right segment's lift over the left
        raw_upper_cis[k] = -proportion_test$conf.int[1]
        row_names[k] = paste(dimnames(data)$segment[i],"vs",dimnames(data)$segment[j])
        k = k+1
      }
    }
  }
  #save result as dataframe
  results = data.frame(pair = row_names, raw_p_value = raw_p_values, raw_lower_ci = raw_lower_cis, raw_upper_ci = raw_upper_cis)
  #order ascending on raw p values
  results = results[order(results$raw_p_value),]
  #compute adjusted p-values
  adj_p_values = p.adjust(results$raw_p_value, method = method)
  #placeholder
  adj_p_values_str = c()
  fin_lower_cis = c()
  fin_upper_cis = c()
  #flagging significant adjusted p values
  #also, only showing confidence interval when the test is significant
  for(i in 1:length(adj_p_values)){
    if(adj_p_values[i]<alpha) {
      adj_p_values_str[i] = paste(toString(round(adj_p_values[i],rounding)),"*")
      fin_lower_cis[i] = results$raw_lower_ci[i]
      fin_upper_cis[i] = results$raw_upper_ci[i]
    } else {
      adj_p_values_str[i] = toString(round(adj_p_values[i],rounding))
      fin_lower_cis[i] = NA
      fin_upper_cis[i] = NA
    }
  }
  #add as columns
  results$adj_p_value = adj_p_values_str
  results$lower_ci = fin_lower_cis
  results$upper_ci = fin_upper_cis
  #drop unnecessary columns
  drops = c("raw_lower_ci", "raw_upper_ci")
  results = results[, !(names(results) %in% drops)]
  #re-ordering by index
  results$index = as.numeric(row.names(results))
  results = results[order(results$index),! names(results) == "index"]
  #output
  results
}

# wrapper end-to-end function
holistic_abtest <- function(data, method = "BH", alpha = 0.05, rounding = 10) {
  #data format for chi square test
  formatted_data = as.table(cbind(data[,1], data[,2] - data[,1])) 
  dimnames(formatted_data) = dimnames(data)
  if(chisq.test(formatted_data)$p.value<alpha) {
    posthoc_abtest(formatted_data, method = method, alpha = alpha, rounding = rounding)
  } else  {
    print("Chi-Square test not significant")
  } 
}
