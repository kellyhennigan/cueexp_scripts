library(dplyr)
library(lme4)
library(e1071)
library(lmtest)
library(lubridate)
library(knitr)
library(BaylorEdPsych)

data_path <- '/Volumes/pegasus/fmrirelapse/paper_figs/relapse_data/relapse_data_171107.csv'
setwd('/Volumes/pegasus/fmrirelapse/paper_figs/nick_relapse')
df <- read.csv(data_path)
df$relapse <- as.factor(df$relapse)
df$relIn6Months <- as.factor(df$relIn6Mos)
df$Subject <- df$subj

df <- filter(df, Subject !='tf151127', Subject!= 'er171009')

relapsers <- filter(df, relIn6Months==1)
abstain = filter(df, relIn6Months==0)

rc <- cor(relapsers$nacc_drugs_beta, relapsers$pa_drug, use="complete.obs")
ac <- cor(abstain$nacc_drugs_beta, abstain$pa_drug, use="complete.obs")
rb <- summary(lm(nacc_drugs_beta ~ pa_drug, data=relapsers))$coefficients[2]
rse  <- summary(lm(nacc_drugs_beta ~ pa_drug, data=relapsers))$coefficients[4]

ab <-  summary(lm(nacc_drugs_beta ~ pa_drug, data=abstain))$coefficients[2]
ase  <- summary(lm(nacc_drugs_beta ~ pa_drug, data=abstain))$coefficients[4]

b1 <- c("Drugs", "Relapse", rb, rse)
b2 <- c("Drugs", "Abstain", ab, ase)

l1 <- c("Drugs", "Relapse", rc)
l2 <- c("Drugs", "Abstain", ac)

rc <- cor(relapsers$nacc_food_beta, relapsers$pa_food, use="complete.obs")
ac <- cor(abstain$nacc_food_beta, abstain$pa_food, use="complete.obs")
l3 <- c("Food", "Relapse", rc)
l4 <- c("Food", "Abstain", ac)

rb <- summary(lm(nacc_food_beta ~ pa_food, data=relapsers))$coefficients[2]
rse  <- summary(lm(nacc_food_beta ~ pa_food, data=relapsers))$coefficients[4]

ab <-  summary(lm(nacc_food_beta ~ pa_food, data=abstain))$coefficients[2]
ase  <- summary(lm(nacc_food_beta ~ pa_food, data=abstain))$coefficients[4]

b3 <- c("Food", "Relapse", rb, rse)
b4 <- c("Food", "Abstain", ab, ase)


rc <- cor(relapsers$nacc_neutral_beta, relapsers$pa_neut, use="complete.obs")
ac <- cor(abstain$nacc_neutral_beta, abstain$pa_neut, use="complete.obs")
l5 <- c("Neutral", "Relapse", rc)
l6 <- c("Neutral", "Abstain", ac)

rb <- summary(lm(nacc_neutral_beta ~ pa_neut, data=relapsers))$coefficients[2]
rse  <- summary(lm(nacc_neutral_beta ~ pa_neut, data=relapsers))$coefficients[4]

ab <-  summary(lm(nacc_neutral_beta ~ pa_neut, data=abstain))$coefficients[2]
ase  <- summary(lm(nacc_neutral_beta ~ pa_neut, data=abstain))$coefficients[4]

b5 <- c("Neutral", "Relapse", rb, rse)
b6 <- c("Neutral", "Abstain", ab, ase)

library(ggplot2)
cors <- data.frame(rbind(l1, l2, l3, l4, l5, l6))
colnames(cors) <- c("Stimulus", "Condition", "Cor")


ggplot(cors, aes(x=Stimulus, y=Cor, fill="Condition")) + 
  geom_bar(aes(fill=Condition),  stat='identity', position="dodge")

bets<- data.frame(rbind(b1, b2, b3, b4, b5, b6))
colnames(bets)<- c("Stimulus", "Condition", "Beta", "SE")
bets$Beta <- as.numeric(levels(bets$Beta)[as.numeric(bets$Beta)])
bets$SE <- as.numeric(levels(bets$SE)[as.numeric(bets$SE)])

ggplot(bets, aes(x=Stimulus, y=Beta, fill=Condition)) + 
  geom_bar(aes(fill=Condition),  stat='identity', position="dodge") + 
  geom_errorbar(aes(ymin=Beta-SE, ymax=Beta+SE), position="dodge")


evalClassifier <- function(df, formula, type='glm', split.method='8020', sep.subjects=FALSE, print.model=FALSE){
  # first get rid of any rows in which one of our variables is NA)
  formula.vars <- unlist(strsplit(gsub("[^[:alnum:]|'_' ]", "", as.character(formula)), c(' ')))
  for(v in formula.vars){
    if(v %in% colnames(df)) {
      df <- df[!is.na(df[v]), ]
    }
  }
  # make our results data frame. 
  d.res <<- data.frame()
  if(sep.subjects){
    print("No separate subject implementation here.")
  } else {
    if(split.method=='loso'){
      
      #eval_model on each subjects
      if(type=='glm'){
        print("Evaluating Entire Model")
        # first evaluate the entire model so as to print model summary information
        .evalClassifier(df, formula, type, split.method = 'none', print.model = print.model)
        
      }
      print("Beginning LOSO...")
      for(subj in unique(df$Subject)){
        print(paste("Testing:",subj))
        accuracies <<- .evalClassifier(df, formula, type, split.method, test.sub=subj, print.model = print.model)
        d.res<<- rbind(d.res, data.frame(Subject=subj, accuracies))
      }
      d.res <- d.res[order(-d.res$test.accuracy),] # order the subjects by their classifier accuracy
      # add the average of all the subjects
      d.res<- rbind(d.res, data.frame(Subject='Average', t(colMeans(d.res[,-1]))))
    } else{
      accuracies <- .evalClassifier(df, formula, type, split.method, print.model=TRUE)
      d.res <- rbind(d.res, data.frame(data='All', accuracies))
    }
  }
  d.res
}
.evalClassifier <- function(df, formula, type='glm', split.method='loso', test.sub = '',  print.model=FALSE){
  y <- all.vars(formula)[1] # get the y variable name to do train test splits
  set.seed(0)
  if(split.method=='none' && type=='glm'){
    m <- fitModel(df, df, formula, type, print.model=TRUE)
    return()
  } else {
    train.accuracies <- c()
    test.accuracies <- c()
    for(i in 1:10){
      train.test <<- trainTestSplit(df, split.method, y=y,test.sub=test.sub)
      m <- fitModel(df, train.test$train, formula, type, print.model)
      train.accuracies<- append(train.accuracies,  modelAccuracy(m, y, train.test$train, type))
      test.accuracies<- append(test.accuracies,  modelAccuracy(m, y, train.test$test, type))
     
      if(split.method=='loso'){
        test.accuracy  <- modelAccuracy(m, y, train.test$test, type)#, one_prediction=T)
      } else{
        test.accuracy  <- modelAccuracy(m, y, train.test$test, type)
      }
      #return(list('train.accuracy'=train.accuracy, 'test.accuracy'=test.accuracy[1], 'prediction'=test.accuracy[2], 'ground.truth' = test.accuracy[3])))
      
    }
    test.accuracy<- mean(test.accuracies)
    train.accuracy<- mean(train.accuracies)
    #print(test.accuracies)
    return(list('train.accuracy'=train.accuracy, 'test.accuracy'=test.accuracy)) #[1])
  }
}

trainTestSplit <- function(df, split.method='8020', y='result', test.sub="", downsample=TRUE){
  
  # Assume that the two responses are levels 1, 2 of a factor
  traindf <- df[df$Subject!=test.sub,]
  ind1 <- which(as.numeric(traindf[,y])==2)
  ind0 <- which(as.numeric(traindf[,y])==1)
  
  # downsample results. to upsample, use max and replace = TRUE
  # uncomment section below for one_subj
  if(downsample){
    sampsize <- min(length(ind1), length(ind0))
    sampind1 <- sample(ind1, sampsize, replace = FALSE)
    sampind0 <- sample(ind0, sampsize, replace = FALSE)
    sampind <- sample(c(sampind1,sampind0)) # the outside call to sample should randomize    
  } else{
    sampind <- sample(1:nrow(df))
  }
  
  balanced.df <- traindf[sampind,]
  
  #Change response levels to 0,1 from 1, 2
  balanced.df[,y] <- factor(as.numeric(balanced.df[,y])-1, levels=c(0,1))
  
  #return last day
  if(split.method=='8020'){
    nrows <- nrow(balanced.df)
    train.ind <- sample(1:nrows, size=floor(.8 * nrows))
    test.ind <- c(1:nrows)[!c(1:nrows) %in% train.ind]
    d.train = balanced.df[train.ind,]
    d.test  =balanced.df[test.ind,]
    l <- list("train" = d.train, "test" = d.test)
  } else if(split.method=='loso'){
    train.ind <- balanced.df$Subject!= test.sub
    test.ind <- df$Subject==test.sub
    d.train <<- balanced.df
    d.test  <<- df[test.ind,]
    l <- list("train" = d.train, "test" = d.test)
  } else {
    print('trainTestSplit called with split.method != 8020 or loso')
  }
  l
}

modelAccuracy <- function(m, y, d.test, type='glm', one_prediction=FALSE){
  
  if(type=='glm'){
    pred = predict(m, newdata = d.test, type = 'response', allow.new.levels = TRUE)
    pred.bin = factor(ifelse(pred >= 0.5,1,0), levels = c(0,1))
  }
  
  if(type=='svm'){
    pred = predict(m, d.test)
    pred.bin <- factor(as.numeric(pred), levels=c(1,2), labels=c(0,1))
  }
  
  if(type=='naivebayes'){
    pred = predict(m, d.test, type='raw')[,2]
    pred.bin = factor(ifelse(pred >= 0.5,1,0), levels = c(0,1))
  }
  
  if(one_prediction){
    prediction <- as.integer(pred.bin[1]) - 1
  }
  class.tab = table(real=d.test[,y], model=pred.bin)
  #print(class.tab)
  acc <- (class.tab[1,1])/sum(class.tab)
  try(acc <- acc +  class.tab[2,2]/sum(class.tab))
  
  if(one_prediction){
    return(c(acc, prediction, as.integer(d.test[,y][1])-1))
  }
  acc
}

fitModel <- function(df, d.train, formula, type='glm', print.model=TRUE){
  # glimpse(d.train)
  needs.multilevel <- '|' %in% unlist(strsplit(gsub("[^[:alnum:]|'_' ]", "", as.character(formula)), c(' ')))
  if(type=='glm'){
    if(needs.multilevel){
      null_formula <- as.formula(paste(as.character(formula)[2], '~', '(1 | Subject)'))
      model <- glmer(formula, data = df, family = binomial(link = logit), control=glmerControl(optimizer="bobyqa"))

      m2 <- glmer(null_formula, data = df, family = binomial(link = logit), control=glmerControl(optimizer="bobyqa"))
      
      if(print.model){
        print(summary(model), correlation=T)
        if(needs.multilevel){ 
          print(rsquared.glmm(model))
        }
        print(lrtest(m2, model))
        print(anova(model))
        #print(confint(model))
      }
      model <- glmer(formula, data = d.train, family = binomial(link = logit), control=glmerControl(optimizer="bobyqa"))
      
    } else{
      null_formula <- as.formula(paste(as.character(formula)[2], '~', '1'))
      model <- glm(formula, data=df, family="binomial")

      m2 <- glm(null_formula, data=df, family="binomial")
      
      if(print.model){
        print(summary(model))
        print("Scaled Coefs:")
        print(scale(model$coefficients, center=F, scale=T))
        print(PseudoR2(model))
        print(lrtest(m2, model))
        print(anova(model))
      }
      #print(summary(d.train))
      model <- glm(formula, data=d.train, family="binomial")
    }
    
    
  }
  if(type=='svm'){
    model <- svm(formula, data=d.train)
  }
  if(type=='naivebayes'){
    if(needs.multilevel){
      print('naiveBayes cannot handle interaction terms')
    } else{
      model <-  naiveBayes(formula, data=d.train)
    }
  }
  model <<- model
  model
}

formula <- as.formula("relIn6Months~ nacc_drugs_beta + vta_drugs_beta + mpfc_drugs_beta +  years_of_use + poly_drug_dep + craving + bam_upset + clinical_diag + age + smoke ")
res <- evalClassifier(df, formula, type='glm', split.method='loso')

print(res)

# Basic logit models for relapse prediction table (rescale brain variables?)

formula <- as.formula("relIn6Months ~ years_of_use + poly_drug_dep + clinical_diag ")
res <- evalClassifier(df, formula, type='glm', split.method='loso')
print(res)

formula <- as.formula("relIn6Months ~ pref_drug + craving + bam_upset ")
res <- evalClassifier(df, formula, type='glm', split.method='loso')
print(res)

formula <- as.formula("relIn6Months ~ mpfc_drugs_beta + nacc_drugs_beta + vta_drugs_beta ")
res <- evalClassifier(df, formula, type='glm', split.method='loso')
print(res)

df$years_of_use_scaled <- scale(df$years_of_use)
df$bam_upset_scaled <- scale(df$bam_upset)
formula <- as.formula("relIn6Months~ nacc_drugs_beta +  years_of_use_scaled   + bam_upset_scaled ")
res <- evalClassifier(df, formula, type='glm', split.method='loso')
print(res)

# formula <- as.formula("relIn6Months~ nacc_drugs_TR567mean + years_of_use + bam_upset")
# res <- evalClassifier(df, formula, type='glm', split.method='loso')
# print(res)
# 
# 
