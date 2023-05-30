library(bupaR)
library(daqapo)
library(processmapR)
library(htmlwidgets)
library(processanimateR)
library(eventdataR)
library(dplyr)

Sys.setenv(PATH = paste(c(Sys.getenv("PATH"), "C:\\Program Files\\RStudio\\bin\\quarto\\bin\\tools"), collapse = ""))

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Args set up for testing outside the model
#args[1] <- "C://Users/bking/Desktop/DAM/MITRE ATTACK Framework/Input Files/New Version/AttackSequences.txt"
#args[2] <- "C://Users/bking/Desktop/DAM/MITRE ATTACK Framework/Input Files/New Version"

#args[1] <- "C://Users/bking/Desktop/DAM/MITRE ATTACK Framework/Model/AttackSequences.txt"
#args[2] <- "C://Users/bking/Desktop/DAM/MITRE ATTACK Framework/Model"

#read the sequence data into a dataframe from processing
origAttackFrame <- read.table(args[1], sep="\t", fill = TRUE, header=TRUE)

#check the size of the table 
dim(origAttackFrame)

#add extra resource and instance columns to the table to put in correct format for event log
resourceCol <- rep(c("r1"), times = nrow(origAttackFrame))
origAttackFrame$Instance <- 1:nrow(origAttackFrame)
origAttackFrame$Resource <- resourceCol

#Format time stamp
origAttackFrame[['Time.Stamp']] <- as.POSIXct(origAttackFrame[['Time.Stamp']],format = "%Y-%m-%d %H:%M:%S")

# Add new column to data frame
updatedAttackFrame <- origAttackFrame %>% mutate(PathTechnique = if_else(Next.Cap =="N/A", paste(Next.Node, Flow, sep = "->"), paste(Next.Node, Threat.Action, sep = "->")))

# Add new column to data frame
updatedAttackFrame <- updatedAttackFrame %>% mutate(SourceTargetTechnique = paste(Source, Target, sep = "/"))
updatedAttackFrame <- updatedAttackFrame %>% mutate(SourceTargetTechnique = paste(SourceTargetTechnique, Threat.Action, sep = "->"))

#check the size of the updated table for debug purposes 
#dim(updatedAttackFrame)

#write the updated table to a file for debug purposes
#write.table(updatedAttackFrame, file = "updatedAttackFrame -test.txt", quote=FALSE, sep="\t", row.names=FALSE)

#check first couple of rows or last couple of rows for debug purposes
#head(updatedAttackFrame)
#tail(attackFrame)

#**********Successful Impacts
#filter Transactions which had an effect
filteredFrame <- filter(updatedAttackFrame, Completed.Effect.on.Target==1)
completedEffectOnTargetFrame <- filter(updatedAttackFrame, Completed.Effect.on.Target==1)

#grab the transaction ids for the effect ones
allTransList <- completedEffectOnTargetFrame$Transaction.Number

#get the unique numbers
completedTransactions <- unique(allTransList)
#print list for debug
#print(completedTransactions)

#grab the flows for the impact ones
allFlowList <- completedEffectOnTargetFrame$Flow
#get the unique numbers
completedFlows <- unique(allFlowList)

#Grab all steps for transactions that had an effect on the target
filteredFrame <- filter(updatedAttackFrame, Transaction.Number %in% completedTransactions & Flow %in% completedFlows )
#check the size of the filtered table for debug purposes 
#dim(filteredFrame)

#show Drew list
#filter again to pull out the end of tier transactions.
completedTierFrame <- filter(filteredFrame, Completed.Tier==1)

#Filter to get the rows which represent the completions of the Tier 
ImpactsFrame <- filter(filteredFrame, Reached.Target==1)
#check the size of the filtered Impact table for debug purposes 
#dim(ImpactsFrame)

#show successful Paths - Techniques
myLog <- eventlog(ImpactsFrame, case_id="Transaction.Number", activity_id = "Threat.Action", activity_instance_id = "Instance",  lifecycle_id =  "Reached.Target", timestamp = "Time.Stamp", resource_id = "Resource")
p = process_map(myLog, type = frequency("absolute"))
fileName1 <- paste(args[2], "\\SuccessfulImpactsAll - Techniques.html",sep="")
graphTitle <- paste("All")
saveWidget(p, file=fileName1, selfcontained = FALSE, title = graphTitle)

#show successful Paths - Tiers
myLog <- eventlog(completedTierFrame, case_id="Transaction.Number", activity_id = "Next.Node", activity_instance_id = "Instance",  lifecycle_id =  "Reached.Target", timestamp = "Time.Stamp", resource_id = "Resource")
p = process_map(myLog, type = frequency("absolute"))
fileName1 <- paste(args[2], "\\SuccessfulImpactsAll - Tiers.html",sep="")
graphTitle <- paste("All")
saveWidget(p, file=fileName1, selfcontained = FALSE, title = graphTitle)

#show successful Paths - Tiers with Techniques
myLog <- eventlog(completedTierFrame, case_id="Transaction.Number", activity_id = "PathTechnique", activity_instance_id = "Instance",  lifecycle_id =  "Reached.Target", timestamp = "Time.Stamp", resource_id = "Resource")
p = process_map(myLog, type = frequency("absolute"))
fileName1 <- paste(args[2], "\\SuccessfulImpactsAll - Tiers Techniques.html",sep="")
graphTitle <- paste("All")
saveWidget(p, file=fileName1, selfcontained = FALSE, title = graphTitle)

#show successful top 10 Paths - Tiers with Techniques
topTenFrame <- filter_trace_frequency(completedTierFrame, percentage = 0.10)
myLog <- eventlog(topTenFrame, case_id="Transaction.Number", activity_id = "PathTechnique", activity_instance_id = "Instance",  lifecycle_id =  "Reached.Target", timestamp = "Time.Stamp", resource_id = "Resource")
p = process_map(myLog, type = frequency("absolute"))
fileName1 <- paste(args[2], "\\Top10PercentSuccessfulImpacts - Tiers Techniques.html",sep="")
graphTitle <- paste("Top 10%")
saveWidget(p, file=fileName1, selfcontained = FALSE, title = graphTitle)


#Build separate diagram for each flow - Techniques by flow
for (i in 1:length(completedFlows)) {
  #Filter to get the rows which represent the completions of the Tier 
  ImpactsFrame <- filter(completedTierFrame, Reached.Target==1)
  newFrame <- filter(ImpactsFrame,Flow==completedFlows[i])
  myLog <- eventlog(newFrame, case_id="Transaction.Number", activity_id = "Threat.Action", activity_instance_id = "Instance",  lifecycle_id =  "Reached.Target", timestamp = "Time.Stamp", resource_id = "Resource")
  p = process_map(myLog, type = frequency("absolute"))
  fileName1 <- paste(args[2], "\\SuccessfulImpactsByFlow - Techniques", completedFlows[i], ".html",sep="")
  graphTitle <- paste("Flow ",completedFlows[i])
  saveWidget(p, file=fileName1, selfcontained = FALSE, title = graphTitle)
#  animate_process(myLog)
}
