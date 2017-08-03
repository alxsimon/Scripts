plot_structure <- function(clust,
                           ncut = 100, colour = NULL, 
                           pop_order = NULL, ind_order = NULL,
                           angle_text = 45){
    if(!is.null(ind_order)){
        clust <- clust[order(match(clust$id, ind_order)),]
    }
    if(!is.null(pop_order)){
        clust <- clust[order(match(clust$pop, pop_order)),]
        clust$pop <- factor(clust$pop, levels = pop_order)
    }
    theme_stru <- theme(axis.ticks.x = element_blank(),
                        axis.title = element_blank(),
                        axis.text.x = element_text(angle = angle_text, hjust = 1),
                        plot.margin = unit(c(1, 1, 0, 2), "lines"),
                        legend.position = "none")
    p <- list()
    k <- 1
    for (s in seq(1, nrow(clust), ncut)){
        if (s + ncut - 1 > nrow(clust)){
            e <- nrow(clust)
        } else {e <- s + ncut - 1}
        df <- melt(clust[s:e,], id.vars = c("id","pop"), variable.name = "cluster", value.name = "ancestry")
        df$id <- factor(df$id, levels = unique(df$id))
        df$cluster <- factor(df$cluster)
        pop.labels <- tapply(1:nrow(clust[s:e,]), factor(clust[s:e,]$pop),
                             function(x) clust[s:e,]$id[floor(median(x))])
        vline <- head(cumsum(summary(factor(clust[s:e,2]))), n = -1) + 0.5
        
        p[[k]] <- ggplot(df, aes(x = id, y = ancestry, fill = cluster)) +
            geom_bar(stat = "identity", width = 1) +
            scale_y_continuous(expand = c(0,0)) +
            geom_vline(xintercept = vline, size = 0.5) +
            scale_x_discrete(breaks = pop.labels, labels = names(pop.labels)) +
            theme_stru
        if(!is.null(colour)){
            p[[k]] <- p[[k]] + scale_fill_manual(values = colour)
        }
        k <- k + 1
    }
    fig <- do.call(arrangeGrob, c(p, nrow = length(p)))
    return(fig)
}

#===============================================================================
read_clusters <- function(file, type = "clumpp", K, Nind, ind_names, pop){
    # type: c("str", "clumpp")
    if(type == "str"){
        L <- readLines(file, skipNul = T, warn = F)
        L <- L[(grep("Inferred ancestry of individuals:",L)+2):(grep("Inferred ancestry of individuals:",L)+1+Nind)]
        L <- lapply(strsplit(L, " +"), function(x) x[x != ""])
        clust <- as.data.frame(matrix(unlist(L), ncol = 5+K, byrow = T), stringsAsFactors = F)
        for(j in 6:(5+K)){ clust[,j] <- as.double(clust[,j]) }
        clust %>% select(-c(1,3,5)) %>%
            setNames(c("id","pop", paste0("C", (1:K)))) -> clust
        clust$id <- ind_names
        clust$pop <- pop
        clust <- clust[order(clust$pop),]
    }
    if(type == "clumpp"){
        read.table(file, header = FALSE) %>% 
            select(-c(2,3,5)) %>%
            setNames(c("id","pop", paste0("C", (1:K)))) -> clust
        clust$id <- ind_names
        clust$pop <- pop
    }
    return(clust)
}