calc_phi <- function(hn, alpha, beta){
  f <- function(hn, alpha, beta){
    hn + 2*(hn - hn^2)*(alpha + beta*(2*hn - 1))
  }
  fp <- function(hn, alpha, beta){
    1 + 2*(1 - 2*hn)*alpha + 2*beta*(6*hn - 1 - 6*hn^2)
  }
  fpp <- function(hn, alpha, beta){
    4*alpha + 12*beta*(1 - 2*hn)
  }
  theta <- f(hn, alpha, beta)
  theta_p <- fp(hn, alpha, beta)
  if(sum(theta_p[-1] < 0) > 0 & beta < 0){
    m1i <- min(which(theta_p <= 0))
    m2i <- max(which(theta_p <= 0))
    y <- mean(c(theta[m1i], theta[m2i]))
    if(sum(fpp(hn,alpha,beta) >= 0) > 0 & sum(fpp(hn,alpha,beta) <= 0) > 0){
      inflexion <- min(which(fpp(hn,alpha,beta) >= 0))
      theta[min(which(theta > y)):max(which(theta < y))] <- y
    }
  }
  phi <- theta
  phi[theta <= 0.5] <- sapply(phi[theta <= 0.5], function(x) max(0,x))
  phi[theta > 0.5] <- sapply(phi[theta > 0.5], function(x) min(1,x))
  return(smooth(phi))
}


plot_cline <- function(alpha, beta){
  hn <- seq(0,1,0.005)
  phi <- calc_phi(hn, alpha, beta)
  plot(hn, phi, type="l",
       xlab = "Hybrid index", ylab = "Prob. ancestry")
  abline(c(0,0),c(1,1), lty="dotted")
}

plot_all_clines <- function(parameters, criteria = "excess", param = "both"){
  if(criteria == "excess"){
    if(param == "both"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T & b_excess == T, TRUE, F))
    } else if (param == "either"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T | b_excess == T, TRUE, F))
    } else if(param == "alpha"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T, TRUE, F))
    } else if (param == "beta"){
      parameters <- mutate(parameters, highlight = if_else(b_excess == T, TRUE, F))
    } else {
      warning("Unknown param choice")
    }
  } else {
    if(param == "both"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T & b_outlier == T, TRUE, F))
    } else if (param == "either"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T | b_outlier == T, TRUE, F))
    } else if(param == "alpha"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T, TRUE, F))
    } else if (param == "beta"){
      parameters <- mutate(parameters, highlight = if_else(b_outlier == T, TRUE, F))
    } else {
      warning("Unknown param choice")
    }
  }
  plot(x = c(0,1), y = c(0,1), type = "l", lty = "dotted",
       xlab = "Hybrid index", ylab = "Prob. ancestry")
  for(i in 1:nrow(parameters)){
    hn <- seq(0,1,0.005)
    phi <- calc_phi(hn, parameters$a_median[i], parameters$b_median[i])
    lines(hn, phi,
          col = ifelse(parameters$highlight[i], "black", "grey"))
  }
}

plot_multiclines <- function(parameters, criteria = "excess", param = "both",
                             title = "Genomic clines"){
  if(criteria == "excess"){
    if(param == "both"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T & b_excess == T, TRUE, F))
    } else if (param == "either"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T | b_excess == T, TRUE, F))
    } else if(param == "alpha"){
      parameters <- mutate(parameters, highlight = if_else(a_excess == T, TRUE, F))
    } else if (param == "beta"){
      parameters <- mutate(parameters, highlight = if_else(b_excess == T, TRUE, F))
    } else {
      warning("Unknown param choice")
    }
  } else {
    if(param == "both"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T & b_outlier == T, TRUE, F))
    } else if (param == "either"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T | b_outlier == T, TRUE, F))
    } else if(param == "alpha"){
      parameters <- mutate(parameters, highlight = if_else(a_outlier == T, TRUE, F))
    } else if (param == "beta"){
      parameters <- mutate(parameters, highlight = if_else(b_outlier == T, TRUE, F))
    } else {
      warning("Unknown param choice")
    }
  }
  p <- qplot(xlim = c(0,1), ylim = c(0,1)) +
    xlab("Hybrid index") +
    ylab(expression(paste("Prob. ancestry P2 (", Phi[i], ")", sep = ""))) +
    ggtitle(title) +
    coord_fixed() +
    theme_classic() +
    geom_abline(slope = 1, intercept = 0, linetype = "dotted")
  for(i in 1:nrow(parameters)){
    hn <- seq(0,1,0.005)
    phi <- as.numeric(calc_phi(hn, parameters$a_median[i], parameters$b_median[i]))
    p <- p + geom_line(data = data.frame(hn, phi),
                       aes(hn, phi),
                       colour = ifelse(parameters$highlight[i], "black", "grey"),
                       alpha = 0.7)
  }
  return(p)
}
