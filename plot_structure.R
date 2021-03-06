require(reshape2)
require(gridExtra)

plot_structure <- function(clust,
													 ncut = 100, colour = NULL, 
													 pop_order = NULL, ind_order = NULL,
													 angle_text = 45,
													 return.list = FALSE,
													 textsize.y = 6,
													 textsize.x = 6,
													 hjust_label = 1,
													 alternate_labels = F){
  if(is_tibble(clust)){
    clust <- as.data.frame(clust)
  }
  if(!is.null(ind_order)) {
    clust <- clust[order(match(clust$ind, ind_order)),]
  }
  if(!is.null(pop_order)) {
    clust <- clust[order(match(clust$pop, pop_order)),]
    clust$pop <- factor(clust$pop, levels = pop_order)
  }
  if(is.null(pop_order) & is.null(ind_order)) {
    clust <- clust[order(clust$pop), ]
  }
  theme_stru <- theme(axis.ticks.x = element_blank(),
                      axis.title = element_blank(),
                      axis.text.x = element_text(angle = angle_text, hjust = hjust_label, size = textsize.x),
                      axis.text.y = element_text(size = textsize.y),
                      plot.margin = margin(5, 5, 0, 5, unit = "pt"),
                      legend.position = "none")
  p <- list()
  k <- 1
  for (s in seq(1, nrow(clust), ncut)){
    if (s + ncut - 1 > nrow(clust)){
      e <- nrow(clust)
    } else {e <- s + ncut - 1}
    df <- melt(clust[s:e,], id.vars = c("ind","pop"), variable.name = "cluster", value.name = "ancestry")
    df$ind <- factor(df$ind, levels = unique(df$ind))
    df$cluster <- factor(df$cluster)
    pop.labels.pos <- tapply(1:nrow(clust[s:e,]), factor(clust[s:e,]$pop),
    												 function(x) clust[s:e,]$ind[floor(median(x))])
    pop.labels.text <- names(pop.labels.pos)
    if(alternate_labels){
    	pop.labels.text <- sapply(seq_along(pop.labels.text), 
    														function(i) paste0(ifelse(i %% 2 == 0, '\n', ''), pop.labels.text[i]))
    }
    vline <- head(cumsum(summary(factor(clust[s:e,2]))), n = -1) + 0.5
    
    
    p[[k]] <- ggplot(df, aes(x = ind, y = ancestry, fill = cluster)) +
      geom_bar(stat = "identity", width = 1) +
      scale_y_continuous(expand = c(0,0)) +
      geom_vline(xintercept = vline, size = 0.5) +
    	scale_x_discrete(breaks = pop.labels.pos, labels = pop.labels.text) +
      theme_stru
    if(!is.null(colour)){
      p[[k]] <- p[[k]] + scale_fill_manual(values = colour)
    }
    k <- k + 1
  }
  if (return.list){
    return(p)
  } else {
    fig <- do.call(arrangeGrob, c(p, nrow = length(p)))
    return(fig)
  }
}

#===============================================================================

plot_structure_vertical <- function(clust,
																		ncut = 100, colour = NULL, 
																		pop_order = NULL, ind_order = NULL,
																		angle_text = 45,
																		return.list = FALSE,
																		textsize.y = 6,
																		textsize.x = 6){
	if(is_tibble(clust)){
		clust <- as.data.frame(clust)
	}
	if(!is.null(ind_order)) {
		clust <- clust[order(match(clust$ind, ind_order)),]
	}
	if(!is.null(pop_order)) {
		clust <- clust[order(match(clust$pop, pop_order)),]
		clust$pop <- factor(clust$pop, levels = pop_order)
	}
	if(is.null(pop_order) & is.null(ind_order)) {
		clust <- clust[order(clust$pop),]
	}
	theme_stru <- theme(axis.ticks.y = element_blank(),
											axis.title = element_blank(),
											axis.text.y = element_text(angle = angle_text, hjust = 1, size = textsize.x),
											axis.text.x = element_text(size = textsize.y),
											plot.margin = margin(5, 5, 0, 5, unit = "pt"),
											legend.position = "none")
	p <- list()
	k <- 1
	for (s in seq(1, nrow(clust), ncut)){
		if (s + ncut - 1 > nrow(clust)){
			e <- nrow(clust)
		} else {e <- s + ncut - 1}
		rev_clust <- clust[e:s, ]
		df <- melt(rev_clust, id.vars = c("ind","pop"), variable.name = "cluster", value.name = "ancestry")
		df$ind <- factor(df$ind, levels = unique(df$ind))
		df$cluster <- factor(df$cluster)
		pop.labels <- tapply(1:nrow(rev_clust), factor(rev_clust$pop),
												 function(x) rev_clust$ind[floor(median(x))])
		vline <- head(cumsum(summary(factor(rev_clust[, 2]))), n = -1) + 0.5
		vline <- -1*(vline - nrow(rev_clust)) + 1
		
		p[[k]] <- ggplot(df, aes(x = ind, y = ancestry, fill = cluster)) +
			geom_bar(stat = "identity", width = 1) +
			scale_y_continuous(expand = c(0,0)) +
			geom_vline(xintercept = vline, size = 0.5) +
			scale_x_discrete(breaks = pop.labels, labels = names(pop.labels),
											 limits = rev(levels(df$pop))) +
			coord_flip() +
			theme_stru
		if(!is.null(colour)){
			p[[k]] <- p[[k]] + scale_fill_manual(values = colour)
		}
		k <- k + 1
	}
	if (return.list){
		return(p)
	} else {
		fig <- do.call(arrangeGrob, c(p, ncol = length(p)))
		return(fig)
	}
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
      setNames(c("ind","pop", paste0("C", (1:K)))) -> clust
    clust$ind <- ind_names
    clust$pop <- pop
    clust <- clust[order(clust$pop),]
  }
  if(type == "clumpp"){
    read.table(file, header = FALSE) %>% 
      select(-c(2,3,5)) %>%
      setNames(c("ind","pop", paste0("C", (1:K)))) -> clust
    clust$ind <- ind_names
    clust$pop <- pop
  }
  return(clust)
}
