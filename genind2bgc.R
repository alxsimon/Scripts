# inspired by this https://popgencode.wordpress.com/2015/04/17/preparing-data-file-bgc-genotype-count/
require(adegenet)
require(forcats)

genind2bgc <- function(X, groups, prefix = "bgc", path = "./", uniquePop = F, loci_used = F,
                       int.as.admix = F, admix.grps = NULL){
  # This function takes an adegenet genind object
  # to convert it to 3 bgc input files
  # requires libraries adegenet and forcats
  # - X is a genind object
  # - 'groups' must be a list of the following structure (respect order)
  # list(P1 = vector("populations Parental 1"),
  #      admix = vector("admixed populations"),
  #      P2 = vector("populations Parental 2"),
  #      exclude = vector("individuals to exclude from the analysis"))
  # - uniquePop: if TRUE, merge all admixed populations together.
  # - loci_used: if TRUE, return a vector of used loci (as some of them may be dropped due to being fixed)

  if(class(X) != "genind"){
    stop("The data must be a genind object")
  }
  if(is.null(X@pop)){
    stop("@pop is empty, required to select populations")
  }
  if(class(groups) != "list"){
    stop("groups must be a list")
  }

  # Drop monomorphic loci in this HZ
  if(all(g@loc.n.all==1)){
    loci_rm <- locNames(X)[X@loc.n.all==1]
    X <- X[loc=which(X@loc.n.all == 2)]
    cat("Monomorphic loci removed:\n")
    cat(loci_rm, sep = "\n")
  }

  # Drop excluded individuals
  if (!is.null(groups$exclude)){
    X <- X[!indNames(X) %in% groups$exclude, ]
  }

  # Parental populations
  gp <- X[X@pop %in% c(groups[[1]], groups[[3]]), ]
  gp@pop <- fct_collapse(gp@pop,
                         P1 = groups[[1]],
                         P2 = groups[[3]])
  gp@pop <- fct_relevel(gp@pop, "P1", "P2")
  gp <- genind2genpop(gp, quiet = T)
  allele_count <- t(gp@tab)
  loci <- unlist(lapply(strsplit(rownames(allele_count), "\\."), "[[", 1))
  loci <- loci[duplicated(loci)]
  loci_returned <- loci
  if(sum(grepl("^[0-9]", loci)) > 0){
    loci <- paste0("loc_", loci)
    message("At least one locus name was beginning with a number,
  added the prefix 'loc_' to all names.")
  }

  P1 <- data.frame(
    loci = loci,
    allele_1 = allele_count[c(TRUE,FALSE), 1],
    allele_2 = allele_count[c(FALSE,TRUE), 1],
    row.names = NULL
  )
  P2 <- data.frame(
    loci = loci,
    allele_1 = allele_count[c(TRUE,FALSE), 2],
    allele_2 = allele_count[c(FALSE,TRUE), 2],
    row.names = NULL
  )

  lines_P1 <- rep(NA,2*length(loci))
  lines_P2 <- rep(NA,2*length(loci))
  for(i in 0:(length(loci)-1)){
    lines_P1[2*i+1] <- loci[i+1]
    lines_P1[2*i+2] <- paste(P1$allele_1[i+1], P1$allele_2[i+1])
    lines_P2[2*i+1] <- loci[i+1]
    lines_P2[2*i+2] <- paste(P2$allele_1[i+1], P2$allele_2[i+1])
  }
  fileConn <- file(paste0(path, "/", prefix,"_P1.txt"))
  writeLines(lines_P1, fileConn)
  close(fileConn)
  fileConn <- file(paste0(path, "/", prefix,"_P2.txt"))
  writeLines(lines_P2, fileConn)
  close(fileConn)

  # Admixed populations
  adm <- X[X@pop %in% groups[[2]], ]
  if (uniquePop) {
    adm@pop <- factor(x = rep("pop_0", nInd(adm)))
  }
  if (int.as.admix & !uniquePop) {
    arg_list <- c(list(adm@pop), admix.grps)
    adm@pop <- do.call(fct_collapse, arg_list)
  }
  allele_count <- adm$tab
  allele_count[is.na(allele_count)] <- -9
  lines <- c()
  if (sum(grepl("^[0-9]", levels(adm@pop))) > 0){
    levels(adm@pop) <- paste0("pop_", levels(adm@pop))
    warning("At least one population name was beginning with a number,
  added the prefix 'pop_' to all names.")
  }
  r <- 1
  for(i in 0:(length(loci)-1)){
    lines[r] <- loci[i+1]
    r <- r + 1
    last_ind <- 0
    for(pop in levels(adm@pop)){
      lines[r] <- pop
      r <- r + 1
      first_ind <- last_ind + 1
      last_ind <- table(adm@pop)[pop] + last_ind
      for(j in first_ind:last_ind){
        lines[r] <- paste(allele_count[j, 2*i+1], allele_count[j, 2*i+2])
        r <- r + 1
      }
    }
  }
  fileConn <- file(paste0(path, "/", prefix, "_admixed.txt"))
  writeLines(lines, fileConn)
  close(fileConn)
  if(loci_used == T){
    return(loci_returned)
  }
}
