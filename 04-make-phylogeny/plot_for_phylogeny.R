# Script to plot circles of various colors corresponding with the occurrance of
# various strains of fungi and where they are found
# Written October 9, 2014 by Naupaka Zimmerman naupaka@gmail.com

library("plotrix")
library("ape")

# this library is not on CRAN and needs to be installed manually
# it was downloaded on January 9, 2015 from here:
# http://www.christophheibl.de/Rpackages.html
library("phyloch")

DEBUG <- FALSE

# Load data and set row names (important for later reordering)
data.in <- read.csv("METADATA_forTree_new.csv")
row.names(data.in) <- data.in$Isolate.Rep

# Read in the tree as a phylo object
tree.in <- read.tree("RAxML_bipartitions.result.phy")

# Ladderizing figures out new order for nodes but doesn't change the tip 
# label order internally
tree.in <- ladderize(tree.in, right = TRUE)

# This extracts the new edge (tip) order from the tree object
tip.edge.id.order <- tree.in$edge[tree.in$edge[,2] < length(tree.in$tip.label) + 1,2]

# This creates a vector with the tip labels now in the proper order based on 
# the ladder
tip.label.order <- tree.in$tip.label[tip.edge.id.order]

# This reorders the data table to match the ladderized order
data.in <- data.in[rev(tip.label.order),]

# set up variables for later reuse and to facilitate code readibility
number.rows <- nrow(data.in)
number.columns <- ncol(data.in)
arnold.columns = seq(from = 7, to = number.columns, by = 2)

offset.value <- 6
pdf("Plot.pdf", width=15, height=50)

split.screen(c(1,2))

# Switch to screen 2 to plot the table
screen(2)

# Size table approporately
par(fig = c(0,1.1,0.0127,0.917),
    mar = c(0,0,0,0))

# set up empty plot and add column labels to top
plot(0,0, 
    xlim = c(-5, number.columns - 4), 
    ylim = c(-2, 2 * (number.rows) + 25), 
    type="n", 
    xaxt = "n", yaxt = "n", 
    bty = "n", 
    ylab = "", xlab = "")

bottom.rect <- -0.75
top.rect <- 2 * (number.rows) + 20
left.1.rect <- 3 + offset.value
right.1.rect <- 9 + offset.value
left.2.rect <- 37/3
right.2.rect <- 10 + offset.value
left.3.rect <- 15
right.3.rect <- 9 + 38/3

# Add highlight rectangles behind table data types
rect(left.1.rect, bottom.rect,
     right.1.rect, top.rect, 
     col = "snow2", border = NA)
rect(left.2.rect, bottom.rect, 
     right.2.rect, top.rect, 
     col = "honeydew2", border = NA)
rect(left.3.rect, bottom.rect, 
     right.3.rect, top.rect, 
     col = "lemonchiffon", border = NA)

# Add table column headers
text(x = c(3,4) + (offset.value - 2), y = rep(2 * (number.rows) + 1, 2), 
    labels = names(data.in[,c(5,6)]), srt = 90, adj = 0, cex = 0.5)
text(x = seq(9+1/3, 9+1/3+18*2/3,by = 2/3), 
    y = rep(2 * (number.rows) + 1, 
    length(arnold.columns)), labels = names(data.in[,arnold.columns + 1]), 
    srt = 90, adj = 0, cex = 0.5)

# Initialize tip label vector
stored.tip.labels <- NA

adjusted.x <- seq(9+1/3, 9+1/3+18*2/3,by = 2/3)

# Plot the data row by row
for(row in 1:number.rows){
    
    stored.tip.labels[row] <- 
        if( is.na(data.in$X95.OTU[row]) ){
            paste(data.in$Isolate.Name[row])
        }
        else{
            paste(data.in$Isolate.Name[row], 
                data.in$X95.OTU[row], sep = " - ")
        }
    
    # print OTU (isolate) row labels
    # text(x = 1, y = 2 * (number.rows - row), 
    #    labels = paste(data.in$Isolate.Rep[row], 
    #                   data.in$X95.OTU[row], 
    #                   data.in$X99.OTU[row], sep = " - "), 
    #            cex = 0.5, pos=2)
   
    text(x = 3 + (offset.value - 2), y = 2 * (number.rows - row), 
         labels = data.in$Total.Arnold.isolates[row], cex = 0.5)
    text(x = 4 + (offset.value - 2), y = 2 * (number.rows - row), 
         labels = data.in$Total.Blast.Hits[row], cex = 0.5)

    # plot either fully filled circles if only Arnold collection
    # or GenBank has isolates, and half-circles if both are present
    
    
    for(column in arnold.columns){
        if(data.in[row, column] > 0 & data.in[row, column + 1] > 0){
            if(DEBUG) print(c(row, column, "black and grey"))
            floating.pie(xpos = adjusted.x[which(arnold.columns == column)], 
                         ypos = 2 * (number.rows - row), 
                         x = c(1,1), startpos = pi/2, 
                         col = c("black", "grey"), radius = 0.25)
        }
        else if(data.in[row, column] > 0 & data.in[row, column + 1] == 0){
            if(DEBUG) print(c(row, column, "only black"))
            points(x = adjusted.x[which(arnold.columns == column)], 
                   y = 2 * (number.rows - row), 
                   pch = 21, cex = 1, bg = "black")
        }
        else if(data.in[row, column] == 0 & data.in[row, column + 1] > 0){
            if(DEBUG) print(c(row, column, "only grey"))
            points(x = adjusted.x[which(arnold.columns == column)], 
                   y = 2 * (number.rows - row), 
                   pch = 21, cex = 1, bg = "grey")
        }
        else if(data.in[row, column] == 0 & data.in[row, column + 1] == 0){
            if(DEBUG) print(c(row, column, "white"))
            # add empty white circles when no isolates for either
            points(x = adjusted.x[which(arnold.columns == column)], 
                   y = 2 * (number.rows - row), 
                pch = 1, cex = 1, col = "light grey") 
        }
    }
}


# Switch to screen one and plot phylogeny
screen(1)

# Need to adjust sizing of the phylogeny to match up with the table
par(fig = c(0.3,0.762,0.024,0.9505))

# Plot the tree. Key parameters are to shut off the margin, which 
# allows manual setting of the x.lim value. Otherwise the end of the tip 
# labels get cut off since it isn't allowing enough extra space for long tip
# names
plot(tree.in, use.edge.length = TRUE, show.tip.label = FALSE, no.margin = TRUE, x.lim = 1) #, edge.width = edge.thickness)

# this is the function we need to load the "phyloch" library to use 
node.support(x = tree.in$node.label, mode="edges", cutoff=70, cex=3)

# Get out the detailed info on the plot in order to figure out where to plot 
# lines connecting tips and the data table
plotinfo <- get("last_plot.phylo", envir = .PlotPhyloEnv)

i <- 1
for(ypos in plotinfo$yy[1:367]){
    lines(c(plotinfo$xx[i]+0.01,0.81),c(ypos,ypos), col = "grey71")
    i <- i + 1
}

# Plots the numbers on the tips for troubleshooting
if(DEBUG) tiplabels()

# body(BOTHlabels)[[8]][[3]][[2]][[3]][[11]] <- substitute(rect(xl, yb, xr, yt, col = bg, border = NULL, lwd = 0))

# Add on the generated tip labels, in the ladderized order
# Reversing the order is important, because with phylo.plot
# the first label is plotted at the bottom, not the top

par(fg = "white")
tiplabels(rev(stored.tip.labels), 
          tip.edge.id.order, 
          cex = 0.5, frame = "rect", 
          bg = "white", adj = -0.05)

close.screen(all = TRUE)
dev.off()
