# ---
# title: "pairs plots"
# author: "Kelly MacNiven"
# date: "4/16/2020"
# ---
  
  
#  get libraries & load data
library(GGally)


# load data and define variables 
d0 = read.csv('/Users/kelly/cueexp/data/q_demo_data/data_controls_200603.csv')

d0$FA<-d0$inf_NAcc_fa_controllingagemotion
d0$inverseMD<-1-d0$inf_NAcc_md_controllingagemotion
d0$FA_raw<-d0$inf_NAcc_fa
d0$inverseMD_raw<-1-d0$inf_NAcc_md
d0$basreward<-d0$basrewardresp # shorten var name for plotting 


#pairs plots: BIS subscales and discount rate 
dp = with(d0, data.frame(FA,inverseMD,BIS,BIS_attn,BIS_motor,BIS_nonplan,discount_rate))
pdf(file="/Users/kelly/cueexp/figures_dti/paper_figs/figS2_pairplots/controls_p1.pdf")
ggpairs(dp,upper = list(continuous = wrap(ggally_cor, displayGrid = FALSE)),title="Brain structure correlations with BIS subscales and discount rate") 
dev.off()


#pairs plots: TIPI
dp = with(d0, data.frame(FA,inverseMD,BIS,tipi_extra,tipi_agree,tipi_consci,tipi_emostab,tipi_open))
pdf(file="/Users/kelly/cueexp/figures_dti/paper_figs/figS2_pairplots/controls_p2.pdf")
ggpairs(dp,upper = list(continuous = wrap(ggally_cor, displayGrid = FALSE)), title="Brain structure and TIPI correlations") 
dev.off()


#pairs plots:BIS/BAS and BDI
dp = with(d0, data.frame(FA,inverseMD,BIS,basdrive,basfunseek,basreward,bisbas_bis,BDI))
pdf(file="/Users/kelly/cueexp/figures_dti/paper_figs/figS2_pairplots/controls_p3.pdf")
ggpairs(dp, upper = list(continuous = wrap(ggally_cor, displayGrid = FALSE)), title="Brain structure correlations with BIS/BAS and BDI scores") 
dev.off()


#pairs plots: age, motion, and sex (not for manuscript, just for own reference)
dp = with(d0, data.frame(FA_raw,inverseMD_raw,age,dwimotion,gender))
pdf(file="/Users/kelly/cueexp/figures_dti/paper_figs/figS2_pairplots/controls_p4.pdf")
ggpairs(dp,upper = list(continuous = wrap(ggally_cor, displayGrid = FALSE)),title="FA and 1-MD correlations with age, motion, and sex") 
dev.off()
