.libPaths("/scratch/PI/knutson/rpackages")
library(ggplot2)
library(dplyr)

csvs <- Sys.glob('*.csv')
df <- read.csv(csvs[1], header=F)
columns <- c("Subject", "Cval", "n_features", "Pct_features", "Accuracy","F1", "precision","recall","roc_auc","r2")
colnames(df) <- columns


for(csv in csvs[-1]){
  to_add <- read.csv(csv, header=F)
  colnames(to_add) <- columns
  df <- rbind(df, to_add)
}

averages <- group_by(df, Cval, n_features) %>%
  summarize_all(.funs=mean)


ggplot(averages, aes(x=-Pct_features, y=Accuracy, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('rfe_accuracy.png')

ggplot(averages, aes(x=-Pct_features, y=F1, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated F! with RFE")
ggsave('rfe_rocauc.png')

one_c <- filter(df, Cval==1)

ggplot(one_c, aes(x=-Pct_features, y = Accuracy, color=as.factor(Subject))) +
  geom_jitter() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('subject_rfe_accuracy_c1.png')

df2 <- cbind(df)
df2$Accuracy <- as.numeric(df$Accuracy>.5)
average_50 <- group_by(df2, Cval, n_features) %>%
  summarize_all(.funs=mean)


ggplot(average_50, aes(x=-Pct_features, y=Accuracy, color=as.factor(Cval))) +
  geom_jitter() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('rfe_accuracy50.png')
