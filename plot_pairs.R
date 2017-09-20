---
title: "Pairs plots"
author: "K MacNiven"
date: "September, 8. 2017"
output:
  pdf_document:
    toc: yes
    toc_depth: '2'
  html_document:
    toc: yes
    toc_depth: 2
---

This script plots variable pairs to check out correlations. 
We assume that you import variables in a .csv file in the format. 

Based on code found here: 
  http://personality-project.org/r/r.short.html

~~~~
  var1, var2, ..., varN
~~~~
  
# Library imports
```{r, message=F}
#library(dplyr)
# library(lme4)
# library(e1071)
# library(lmtest)
# library(lubridate)
# library(knitr)
# library(BaylorEdPsych)
library(psych) 
library(lattice)
library(ggplot2)
```

# Load your data. 
```{r}
#rm(list=ls())
data_path <- '/Users/kelly/cueexp/data/relapse_data/relapse_data_170908.csv'
#d <- read.csv(data_path)
d <- read.table(data_path,header=TRUE,sep=",")
names(d)
attach(d)
```


#Clean your data
#```{r}
# #Remove Outliers with > 4 sd 
# max_act  =apply(as.matrix(df[19:113]), 1, function(x) { max(abs(x),na.rm=TRUE) } ) # this finds the largest ROI activation within a row of your data
# hist(max_act)
# df <- df[(max_act<4) & max_act > 0,]
# max_act  =apply(as.matrix(df[19:113]), 1, function(x) { max(abs(x),na.rm=TRUE) } )
# hist(max_act)
#```

#Descriptive stats
```{r}
summary(d)  #print out the min, max, range, mean, median, etc. of the data
describe(d)
```

# define a vector of column indices for just the columns to plot (e.g., exclude subject id, etc.)
```{r}
#ci = c(2:4,6:11,14,17,20,24,25,28,31)
#ci=sapply(d,is.numeric) # determine which columns have numeric data
#ci = c(4,6,9,11,14,17,20,24,25,28,31)
ci = c(2,4,20,24,25,28,31)
ci = c(20,24,25,28,31)

dd = d[ ,ci]
names(dd)
```


# plots
```{r}
#draws scatterplots, histograms, and shows correlations  (source found in the psych package)
png(filename = '/Users/kelly/cueexp/figures/relapse_prediction/pairplots.png',
    units="in",
    width=5,
    height=5,
    res=300)
pairs.panels(dd)
dev.off()
```


```{r}
#my_cols <- c("#00AFBB", "#E7B800", "#FC4E07")  
my_cols <- c("#00AFBB", "#FC4E07")  
pairs(dd, 
      pch = 19,  
      cex = 0.5,
      col = my_cols[d$relapse],
      lower.panel=NULL)

pairs.panels(dd,
      hist.col = my_cols[2]
)

# Correlation panel
panel.cor <- function(x, y){
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits=2)
  txt <- paste0("R = ", r)
  cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}

# Customize upper panel
upper.panel<-function(x, y){
  points(x,y, pch = 19, col = my_cols[as.factor(d$relapse)])
}
# Create the plots
pairs(dd, 
      lower.panel = panel.cor,
      upper.panel = upper.panel)
```


pairs.panels(attitude)   #see the graphics window
data(iris)
pairs.panels(iris[1:4],bg=c("red","yellow","blue")[iris$Species],
             pch=21,main="Fisher Iris data by Species") #to show color grouping

pairs.panels(iris[1:4],bg=c("red","yellow","blue")[iris$Species],
             pch=21+as.numeric(iris$Species),main="Fisher Iris data by Species",hist.col="red") 
#to show changing the diagonal

#to show 'significance'
pairs.panels(iris[1:4],bg=c("red","yellow","blue")[iris$Species],
             pch=21+as.numeric(iris$Species),main="Fisher Iris data by Species",hist.col="red",stars=TRUE) 



#demonstrate not showing the data points
data(sat.act)
pairs.panels(sat.act,show.points=FALSE)
#better yet is to show the points as a period
pairs.panels(sat.act,pch=".")
#show many variables with 0 gap between scatterplots
# data(bfi)
# pairs.panels(bfi,show.points=FALSE,gap=0)

#plot raw data points and then the weighted correlations.
#output from statsBy
sb <- statsBy(sat.act,"education")
pairs.panels(sb$mean,wt=sb$n)  #report the weighted correlations
#compare with 
pairs.panels(sb$mean) #unweighed correlations






