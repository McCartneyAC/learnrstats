# Lesson Fifteen: R to HTML via Markdown, ggvis, SjPlot

# for today's lesson, we're going to do something a little bit different, which is that we'll be 
# using R-Markdown. The goal of this lesson is to produce a reproducible research document to HTML 
# that can be generated on anyone's machine (provided they have the data).

# to that end, we'll be mainly using these three new packages:
install.packages(c("ggvis", "rmarkdown", "sjPlot", "httr"))
library(ggvis)
library(rmarkdown)
library(sjPlot)
library(dplyr)
library(httr)

# how to open an R Markdown Document
....



# A basic workflow to read an xlsx file from the web. 
# note that this is MUCH easier for .csv files because readr can do this directly, 
# whereas readxl cannot. 
url1 <- "https://data.humdata.org/dataset/db1630c9-d0cd-44ba-99a3-e77db9173557/resource/f8d88de0-8972-42b8-9bfc-ac7726701273/download/reach_afg_dataset_ahtra_round2_may2018.xlsx"
httr::GET(url1, write_disk(tf <- tempfile(fileext = ".xlsx")))
reach <- readxl::read_xlsx(tf, 3L)

reach
# this is a dataset that is a basic househould survey of "hard to reach" households in 
# Afghanistan

# we can see all the variables by looking at page 2 of the spreadsheet
codebook <- readxl::read_xlsx(tf, 2L)
codebook # but it doesn't help us too too much. 

View(codebook) # a little better. 

