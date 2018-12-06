# functions to compute missing data in genotype datasets

get_md_ind <- function(X, to.rm = 1:3){
  if(!is.null(to.rm)){
    tmp <- X %>% select(-to.rm) %>% is.na(.) %>% rowMeans(.)
  } else {
    tmp <- X %>% is.na(.) %>% rowMeans(.)
  }
  return(tmp)
}
get_md_loc <- function(X, to.rm = 1:3){
  if (!is.null(to.rm)){
    tmp <- X %>% select(-to.rm) %>% is.na(.) %>% colMeans(.)
  } else {
    tmp <- X %>% is.na(.) %>% colMeans(.)
  }
  return(tmp)
}