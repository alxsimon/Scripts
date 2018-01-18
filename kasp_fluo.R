import_fluo <- function(file) {
    raw_fluo <- read_lines(file)
    start_stat <- grep("Statistics", raw_fluo)
    start_dna <- grep("DNA", raw_fluo)
    start_snps <- grep("SNPs", raw_fluo)
    start_scaling <- grep("Scaling", raw_fluo)
    start_data <- grep("Data", raw_fluo)
    
    stat <- raw_fluo[(start_stat + 1):(start_dna - 2)]
    dna <- raw_fluo[(start_dna + 1):(start_snps - 4)]
    snps <- raw_fluo[(start_snps + 1):(start_scaling - 2)]
    scaling <- raw_fluo[(start_scaling + 1):(start_data - 2)]
    data <- raw_fluo[(start_data + 1):length(raw_fluo)]
    
    fluo <- list()
    #
    fluo$stat <- as_tibble(matrix(unlist(str_split(stat, ",")), ncol = 14, byrow = T))
    names(fluo$stat) <- as.character(fluo$stat[1,])
    fluo$stat <- fluo$stat[-1,]
    #
    fluo$dna <- as_tibble(matrix(unlist(str_split(dna, ",")), ncol = 3, byrow = T))
    names(fluo$dna) <- as.character(fluo$dna[1,])
    fluo$dna <- fluo$dna[-1,]
    #
    fluo$snps <- as_tibble(matrix(unlist(str_split(snps, ",")), ncol = 5, byrow = T))
    names(fluo$snps) <- as.character(fluo$snps[1,])
    fluo$snps <- fluo$snps[-1,]
    #
    fluo$scaling <- as_tibble(matrix(unlist(str_split(scaling, ",")), ncol = 8, byrow = T))
    names(fluo$scaling) <- as.character(fluo$scaling[1,])
    fluo$scaling <- fluo$scaling[-1,]
    #
    fluo$data <- as_tibble(matrix(unlist(str_split(data, ",")), ncol = 13, byrow = T))
    names(fluo$data) <- as.character(fluo$data[1,])
    fluo$data <- fluo$data[-1,]
    #
    fluo$header <- raw_fluo[1:(start_stat - 1)]
    
    return(fluo)
}

write_fluo <- function(fluo, file) {
    write_lines(fluo$header, file)
    cat(paste0("Statistics\n", paste(names(fluo$stat), collapse = ","), "\n"),
        file = file, append = T)
    write_csv(fluo$stat, file, append = T)
    cat(paste0("\nDNA\n", paste(names(fluo$dna), collapse = ","), "\n"),
        file = file, append = T)
    write_csv(fluo$dna, file, append = T)
    note <- "\n# Please note: AL1=AlleleY axis and AL2=AlleleX axis. Allele Y is defined before allele X in the following header;\n\n"
    cat(paste0(note, "SNPs\n", paste(names(fluo$snps), collapse = ","), "\n"),
        file = file, append = T)
    write_csv(fluo$snps, file, append = T)
    cat(paste0("\nScaling\n", paste(names(fluo$scaling), collapse = ","), "\n"),
        file = file, append = T)
    write_csv(fluo$scaling, file, append = T)
    cat(paste0("\nData\n", paste(names(fluo$data), collapse = ","), "\n"),
        file = file, append = T)
    write_csv(fluo$data, file, append = T)
}