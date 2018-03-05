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
    fluo$stat <- as_tibble(read.csv(text = paste(stat, collapse = "\n"), 
                                    stringsAsFactors = F))
    #
    fluo$dna <- as_tibble(read.csv(text = paste(dna, collapse = "\n"),
                                   stringsAsFactors = F))
    #
    fluo$snps <- as_tibble(read.csv(text = paste(snps, collapse = "\n"),
                                    stringsAsFactors = F))
    #
    fluo$scaling <- as_tibble(read.csv(text = paste(scaling, collapse = "\n"),
                                       stringsAsFactors = F))
    #
    fluo$data <- as_tibble(read.csv(text = paste(data, collapse = "\n"),
                                    stringsAsFactors = F))
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