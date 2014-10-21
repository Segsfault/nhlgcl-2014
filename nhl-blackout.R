# quick and dirty R code to support the analysis done at www.segsfault.com/blog
#
setwd('/home/borys/projects/nhl')
library(reshape2)
library(ggplot2)

data<-read.table('schedule-2015.tsv',
                 header=TRUE,sep="\t",
                 colClasses=c('character','character','character','character','character'),
                 col.names=c('date','home','away','time','network'))
home<-data[,c("date","home","network")]
away<-data[,c("date","away","network")]
names(home)[2]<-"team"
names(away)[2]<-"team"
all<-rbind(home,away)
all$NHL<-grepl("NHL",data$network)
all$NBC<-grepl("NBC",data$network)

# Pick just saturday games
#all<-all[grep("Sat",all$date),]

blackouts<-aggregate(NHL~team,data=all,FUN=sum)
blackouts$NBC<-aggregate(NBC~team,data=all,FUN=sum)$NBC

# Lets plot all blacked out games
blackouts$team <- reorder(blackouts$team, -rowSums(blackouts[-1]))
blackouts.m<-melt(blackouts, id=c("team"))
names(blackouts.m)[2]<-"Network"

png(filename="all_blackouts.png",width=600,height=480,units="px")
ggplot(blackouts.m,aes(x = team, y = value,fill=Network)) + 
  geom_bar(width=.9,stat="identity") +
  theme_bw()+
  theme(
    plot.background = element_blank()
    ,panel.grid.major = element_blank()
    ,panel.grid.minor = element_blank()
    ,panel.border = element_blank()
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1,vjust=0.5))+
  xlab("") +
  ylab("") +
  ylim(0, 10) +
  ggtitle("Games blacked out on NHL GameCenterLive") +
  guides(fill=guide_legend(title=NULL)) +
  theme(legend.position=c(.8, .8)) +
  theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))

dev.off()



# NBC only
png(filename="nbc_blackouts.png",width=600,height=480,units="px")
blackouts$team <- reorder(blackouts$team, -blackouts$NBC)
ggplot(blackouts,aes(x = team, y = NBC)) + 
  geom_bar(width=.5,stat="identity") +
  theme_bw()+
  theme(
    plot.background = element_blank()
    ,panel.grid.major = element_blank()
    ,panel.grid.minor = element_blank()
    ,panel.border = element_blank()
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1,vjust=0.5))+
  xlab("") +
  ylab("") +
  ylim(0, 25) +
  ggtitle("Blackouts due to NBC Network (US)") +
  guides(fill=guide_legend(title=NULL)) +
  theme(legend.position=c(.8, .8)) +
  theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))

dev.off()
