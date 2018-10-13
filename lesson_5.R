# Lesson 5: Simple Linear Models and Working Directories

# last lesson for 
date()
# > date()
# [1] "Sat Aug 18 12:58:48 2018"


# R is a statisical language based on linear algebra and vectors
# it's no surprise it's MADE to be used for regression analysis. 

# for this, we're going to learn a bit about working directories as well. 

# we'll use these packages:
library(readxl)
library(ggplot2)

# so we want to use a teacher pay dataset posted by a yours truly here:

# https://github.com/McCartneyAC/teacher_pay/blob/master/data.xlsx

# but the general excel import function doesn't work with github:

pay<-read_xlsx("https://github.com/McCartneyAC/teacher_pay/blob/master/data.xlsx")


# so we are going to download this guy's data and use it from our local machine. 

# Directories:

# Automatically, R has a specified folder where your stuff is stored. This is the folder
# where it looks for files, and it's the default folder for your output as well. 

# where does R think I am on my pc right now?
getwd()

# you have two options: give up and save every new data file to that folder, or change
# your working directory: 
setwd("C:\\Users\\andrew\\Desktop\\teacher_pay")

# So we have made a new folder called "teacher pay" and changed our directory to that
# folder, then we have used the download button on my github page to download
# the excel spreadsheet of teacher data to our new folder. 

# !!! notice how when setting a working directory, all slashes must be be doubled, because
# R reads \ as an "escape." If you forget to double them, trouble awaits. I'm also aware that 
# this may be different on a Mac. Mac users comment below. 

teachers <- read_xlsx("data.xlsx")
teachers

# cool. 

# let's see if there's a relationship between actual teacher pay and cost-of-living-adjusted
# pay. 

teachers %>% 
  ggplot(aes(x = `Actual Pay`, y = `Adjusted Pay` )) +
  geom_point() +
  geom_smooth()

# huh. Okay. 

# we're not learning ggplot2 just yet (soon!)  so I won't go into details
# of how that worked exactly, but you can see that we learned a little bit about
# teacher pay in the U.S. Also we learned that there are some interesting outliers. 

# let's see what the outliers are then move on: 
teachers %>% 
  ggplot(aes(x = `Actual Pay`, y = `Adjusted Pay` )) +
  geom_text(aes(label=Abbreviation)) +
  geom_smooth()

# So if I'm a teacher the lesson is clear: get the hell out of hawaii and move to
# michigan? It doesn't seem worth it. 

# Linear regression.

# like I said, this isn't a lesson on ggplot2; it's a lesson on regression. 

# so let's define a linear model. 

# I have provided us with these variables:
names(teachers)
# let's see what predicts adjusted pay: whether the state had a strike, what the 
# actual pay is, and what percent of the state voted for Trump. 

# to do this, we need a new column (pct_trump) and that means we need to 
# mutate, first. Remember the pipe operator?

teachers <- teachers %>% 
  mutate(pct_trump = (`Trump Votes` / (`Trump Votes` + `Clinton Votes`)))

# we can do 
names(teachers) # again to see if our new column is there, or just call
head(teachers) # to see if the new column has percents:



# so how do we declare a linear model? Simple!

model1 <- lm(`Adjusted Pay` ~ `Actual Pay` + Strike + pct_trump, data = teachers)

# This says, using the teachers data set, we want to make a linear model where
# cost-of-living-adjusted-pay is predicted by pay in dollars unadjusted, whether the
# district had a teacher strike in 2018 (factor), and how many voted for trump in 2016.

#what happens if we call the model?
model1
# not exactly helpful. We want a regression output!

summary(model1)

# Much better! Actual pay is of course the strongest predictor. However, states that went for Trump seem to have had
# higher cost-of-living adjusted pay than states that went for Clinton, even when controlling for actual pay. Weird!
# (Does this have something to do with urbanicity?)

# also, the strike-factor was insignificant (go figure) 

# Also also, I know from our graph that this model should be quadratic, so let's do it again: 
teachers <- teachers %>% 
  mutate(actualsq = `Actual Pay` * `Actual Pay`)

model2<-lm(`Adjusted Pay` ~ actualsq + `Actual Pay` + Strike + pct_trump, data = teachers)

summary(model2)


# that seems to make more sense! We've reduced the overwhelming strength of the two predictors from 
# before while increasing the adjusted R^2 of our model. 

# cool. 



# today we learned:

# # how to change our working directory
# # how to import xlsx spreadsheets
# # how to define a linear model
# # how to create a new variable
# # how to summarize our linear model


# That's it for saturday august 18, folks. More to come tomorrow!
