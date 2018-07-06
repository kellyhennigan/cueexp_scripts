.libPaths("/scratch/PI/knutson/rpackages")
#library(methods)
library(ggplot2)
library(dplyr)

csvs <- Sys.glob('*.csv')
df <- read.csv(csvs[1], header=F)
columns <- c("Subject", "Cval", "n_features", "Pct_features", "Accuracy","F1", "precision","recall","roc_auc","r2", "training_time")
colnames(df) <- columns


for(csv in csvs[-1]){
  to_add <- read.csv(csv, header=F)
  colnames(to_add) <- columns
  df <- rbind(df, to_add)
}

averages <- group_by(df, Cval, n_features) %>%
  dplyr::summarize_all(funs(mean(., na.rm = TRUE)))


ggplot(averages, aes(x=-Pct_features, y=Accuracy, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('rfe_accuracy.png')

ggplot(averages, aes(x=-Pct_features, y=F1, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated F1 with RFE")
ggsave('rfe_f1.png')

ggplot(averages, aes(x=-Pct_features, y=precision, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated precision with RFE")
ggsave('rfe_precision.png')

ggplot(averages, aes(x=-Pct_features, y=recall, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated recall with RFE")
ggsave('rfe_recall.png')

ggplot(averages, aes(x=-Pct_features, y=roc_auc, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated roc_auc with RFE")
ggsave('rfe_rocauc.png')

ggplot(averages, aes(x=-Pct_features, y=r2, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated r2 with RFE")
ggsave('rfe_r2.png')

ggplot(averages, aes(x=-Pct_features, y=training_time, color=as.factor(Cval))) +
  geom_point() +
  geom_line()  +
  ggtitle("Cross-validated r2 with RFE")
ggsave('rfe_training_time.png')


one_c <- filter(df, Cval==1)

ggplot(one_c, aes(x=-Pct_features, y = Accuracy, color=as.factor(Subject))) +
  geom_jitter() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('subject_rfe_accuracy_c1.png')

df2 <- cbind(df)
df2$Accuracy <- as.numeric(df$Accuracy>.5)
average_50 <- group_by(df2, Cval, n_features) %>%
  dplyr::summarize_all(funs(mean(., na.rm = TRUE)))


ggplot(average_50, aes(x=-Pct_features, y=Accuracy, color=as.factor(Cval))) +
  geom_jitter() +
  geom_line()  +
  ggtitle("Cross-validated accuracy with RFE")
ggsave('rfe_accuracy50.png')
