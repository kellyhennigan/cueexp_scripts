# .libPaths("/scratch/PI/knutson/rpackages")
#library(tidyverse)
library(ggplot2)
library(dplyr)

#setwd('/Users/kelly/cueexp/data/betasvm_old/csvs')
#setwd('/Users/kelly/cueexp/data/betasvm_180330/csvs')
#setwd('/Users/kelly/cueexp/data/betasvm_180402/csvs')
#setwd('/Users/kelly/cueexp/data/betasvm_180402_2/csvs')
#setwd('/Users/kelly/cueexp/data/betasvm_180402_3/csvs')
#setwd('/Users/kelly/cueexp/data/betasvm_180430/csvs')
setwd('/Users/kelly/cueexp/data/betasvm_180502/csvs')

csvs <- Sys.glob('*.csv')
df <- read.csv(csvs[1], header=F)
columns <- c("Subject", "Cval", "n_features", "Pct_features", "Accuracy","F1", "precision","recall","roc_auc","r2","traintime")
colnames(df) <- columns
#print(df)

# shorten the string for elastic net classifier
#df$Cval <- as.character(df$Cval)
#df$Cval[df$Cval== "elasticnetiter1000_l1ratio0.15"] <-"enet_l1ratio0.15"
#df$Cval <- as.factor(df$Cval)

# omit elastic net results
df=df[df$Cval !='elasticnetiter1000_l1ratio0.15',]

for(csv in csvs[-1]){
  to_add <- read.csv(csv, header=F)
  colnames(to_add) <- columns
  
  # shorten the string for elastic net classifier
 #to_add$Cval <- as.character(to_add$Cval)
#  to_add$Cval[to_add$Cval== "elasticnetiter1000_l1ratio0.15"] <-"enet_l1ratio0.15"
#to_add$Cval <- as.factor(to_add$Cval)
  
  
  # remove elastic net results 
  to_add=to_add[to_add$Cval !='elasticnetiter1000_l1ratio0.15',]
  
  df <- rbind(df, to_add)
}

averages <- group_by(df, Cval, n_features, Pct_features) %>%
  summarize(Accuracy=mean(Accuracy))


ggplot(averages, aes(x=-Pct_features, y=Accuracy, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ylim(.35,.7)
  ggtitle("Cross-validated accuracy with RFE")
#ggsave('rfe_accuracy_w_enet.png')
ggsave('rfe_accuracy.png')
#max(averages)
