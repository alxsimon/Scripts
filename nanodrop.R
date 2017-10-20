nanodrop <- function(file, is95 = F){
    tb <- read.delim(file, stringsAsFactors = F)
    tb <- tb[1:grep("Sample", tb$Plate.ID)-1,]
    tb$Conc. <- sub(",", ".", tb$Conc.)
    M <- matrix(NA, 8, 12)
    for(j in 0:11){
        for(i in 1:8){
            M[i,j+1] <- as.numeric(tb$Conc.[j*8+i])
        }
    }
    if(is95){
        M[8,12] <- NA
    }
    
    if(is95) stop_row <- 95 else stop_row <- 96
    if(nrow(tb) > stop_row){
        for(i in stop_row:nrow(tb)){
            well <- tb$Well[i]
            C <- as.numeric(sub("[A-H]", "", well))
            R <- which(sub("[1-9]+", "", well) == LETTERS)
            M[R, C] <- tb$Conc.[i]
        }
    }
    
    for(i in 1:8){
        cat(c(M[i,], "\n"))
    }
}
