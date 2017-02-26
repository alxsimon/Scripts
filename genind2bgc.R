# inspired by this https://popgencode.wordpress.com/2015/04/17/preparing-data-file-bgc-genotype-count/

genind2bgc <- function(X, groups, prefix = "bgc", path = "./"){
    # This function takes an adegenet genind object
    # to convert it to 3 bgc input files
    # requires libraries adegenet and forcats
    if(class(X) != "genind"){
        stop("The data must be a genind object")
    }
    if(is.null(X@pop)){
        stop("@pop is empty, required to select populations")
    }
    if(class(groups) != "list"){
        stop("groups must be a list")
    } else {
        if(length(groups) != 3){
            stop("groups must be of length 3")
        }
    }
    
    # Drop monomorphic loci in this HZ
    loci_rm <- locNames(X)[X@loc.n.all==1]
    X <- X[loc=which(X@loc.n.all == 2)]
    cat("loci removed:\n")
    cat(loci_rm, sep = "\n")
    
    # Parental populations
    gp <- X[X@pop %in% c(groups[[1]],groups[[2]]),]
    gp@pop <- fct_collapse(gp@pop,
                           P1 = groups[[1]],
                           P2 = groups[[2]])
    gp@pop <- fct_relevel(gp@pop, "P1", "P2")
    gp <- genind2genpop(gp)
    allele_count <- t(gp@tab)
    loci <- unlist(lapply(strsplit(rownames(allele_count), "\\."), "[[", 1))
    loci <- paste0("loc_", loci[duplicated(loci)])
    
    P1 <- data.frame(
        loci = loci,
        allele_1 = allele_count[c(TRUE,FALSE),1],
        allele_2 = allele_count[c(FALSE,TRUE),1],
        row.names = NULL
            )
    P2 <- data.frame(
        loci = loci,
        allele_1 = allele_count[c(TRUE,FALSE),2],
        allele_2 = allele_count[c(FALSE,TRUE),2],
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
    fileConn <- file(paste0(path, prefix,"_P1.txt"))
    writeLines(lines_P1, fileConn)
    close(fileConn)
    fileConn <- file(paste0(path, prefix,"_P2.txt"))
    writeLines(lines_P2, fileConn)
    close(fileConn)
    
    # Admixed populations
    adm <- X[X@pop %in% groups[[3]],]
    allele_count <- adm$tab
    allele_count[is.na(allele_count)] <- -9
    lines <- c()
    r <- 1
    for(i in 0:(length(loci)-1)){
        lines[r] <- loci[i+1]
        r <- r + 1
        last_ind <- 0
        for(pop in levels(adm@pop)){
            lines[r] <- paste0("pop_", pop)
            r <- r + 1
            first_ind <- last_ind + 1
            last_ind <- table(adm@pop)[pop] + last_ind
            for(j in first_ind:last_ind){
                lines[r] <- paste(allele_count[j,2*i+1], allele_count[j,2*i+2])
                r <- r + 1
            }
        }
    }
    fileConn <- file(paste0(path, prefix, "_admixed.txt"))
    writeLines(lines, fileConn)
    close(fileConn)
}













