# Lesson 14: Machine Learning One: Neural Net with Logistic Regression

# Hello everyone, I've been meaning to do this lesson for a while but it's definitely intermediate
# heading for advanced. This is a first take on Neural Networks; if you don't know what those are, 
# check out some other resources first. This will assume some passing familiarity with the basics
# of the theory. 
# 
# This code is meant only to represent a worked example in R of binary classification, i.e.
# the output of the network will be a 1 (yes) or a 0 (no). (what I think of as logistic regression)
# 
# (very fancy logistic regression)
# 
# This code example is not my original work, but is adapted from
url2 <- http://www.kdnuggets.com/2016/08/begineers-guide-neural-networks-r.html
#  With my own additions and annotations
#  
#  In particular, I have given it a tidyverse overhaul. 

install.packages('ISLR')
library(ISLR) #contains our data set: College. 

library(neuralnet)
library(NeuralNetTools) # via 
url3<-"https://beckmw.wordpress.com/2014/12/20/neuralnettools-1-0-0-now-on-cran/"

library(tidyverse)

# College data set contained within ISLR
college <- College %>% 
  as_tibble() %>%  # we want it as a tibble for tidy work. 
  rownames_to_column("id") #get rid of those pesky row names
college %>%
  psych::describe()

# Now that we have read in our data, what are we trying to do?
# we want to make a neural net that predicts whether a college is public or private.
# perhaps we work in a context where we learn about new colleges often but 
# they never bother to tell us public/private status so we have to predict it from
# data? The example is a bit contrived, especially as compared to other 
# neural net challenges. However, it's what I was given, so we'll work with it. 


# prepare the data ------------------------------------------
# 
# (we need to scale the variables, recode the DV, and split into test/train)


# Create Vector of Column Max and Min Values
maxs <- apply(college[,3:19], 2, max)
mins <- apply(college[,3:19], 2, min)
# first argument is data, second is 1 (rows) or 2 (columns) and third is function to use. 
mins # essentially makes a list of all the data elements by max value and min value for each 
# variable


# Use scale() and convert the resulting matrix to a data frame
scaled_data <- college %>% 
  select(-id, -Private) %>% 
  scale(center = mins, scale = maxs - mins) %>% 
  as_tibble()
# this scales the resultant data frame by those max and mins, centered around the min value 
# (for some reason?)

# Check out results
scaled_data

# Notice how we have lost the id (name) of each school and its public-private status
# variable. we'll work those back in next:

# Convert Private column from Yes/No to 1/0 and then isolate
private <- college %>% 
  mutate(private = if_else(Private == "Yes", 1, 0)) %>% 
  select(id, private)

# rejoin private with the scaled data. 
dat <- cbind(private, scaled_data) %>% 
  as_tibble() 
# we might be tempted to do a full_join here, but there is no "by" variable that is 
# common to both data sets, so this throws an error. If we had kept id in both, we 
# could have done a join. ah well. 
dat <- full_join(private, scaled_data)  

# Why couldn't we have just centered the data and re-coded private in one step?
# the base R function `scale` would not work with the subset of the data in quite
# the same way as we want. 

# I'm not entirely sure what property is garnered by scaling the variables, so perhaps 
# we could have centered them only doing something like this: 

center <- function (df, var, center = 0) {
  user_var <- enquo(var)
  varname <- quo_name(user_var)
  center <- enquo(center)
  mutate(df, !!varname := (!!user_var - !!center))
}

college %>% 
  mutate(private = if_else(Private == "Yes", 1, 0)) %>% 
  center(Apps, min(Apps)) %>% 
  # ... and so on for all 17 numeric variables...
  center(Grad.Rate, min(Grad.Rate))
# and see if we get the same result. 

# Machine Learning Experts in the audience - what is the relative
# benefit of scaling? 

# Now that we have centered the data
set.seed(123) # your number here. 

# Split the data into 70/30 proportions at random:
training_data <- dat %>% 
 sample_frac(0.70, replace = FALSE)
test_data <- dat %>% 
  anti_join(training_data, by = 'id')


# Now prepare the  model -------------------------------

# In general you can just type DV ~ IV1 + IV2 
# and so on, but this tutorial used this trick 
# that extends to any number of IVs in case your data has 
# dozens and you don't feel like typing them all: 

feats <- training_data %>% # (either is fine)
  select(-id, -private) %>% 
  names()

# Concatenate strings
f <- paste(feats, collapse=' + ')
# collapses all the variables by +
f <- paste('private ~',f)
# puts the IV in its place
f

# Convert to formula
f <- as.formula(f)

f

# Now we train the neural net -------------------------------

# training the net runs a bunch of repetitions doing its neural net
# thing on our training data. the arguments are our function, our 
# training data, the structure of the hidden layers, and the structure 
# of our output. I think linear.output = FALSE is giving us a logistic
# output rather than linear, based on a subsequnt change in activation
# function. Youcan also select your algorithm, weights, etc. via additional arguments:
?neuralnet

nn <- neuralnet(f, training_data, hidden=c(10,10,10), linear.output=FALSE)
# nn <- neuralnet(f, training_data, hidden=12, linear.output=FALSE) # one hidden layer


# There. It's all trained up. 

# You can use base R plotting to see the net
plot(nn) 
# But obviously you shouldn't.


# Compute Predictions off Test Set
predicted_nn <- neuralnet::compute(nn,test_data[3:19])

# this is the nn analogue to predict(model1).
# 
# NOTE: dplyr also  has a function "compute" so if you aren't careful
# this can throw an error (hence inlcuding the library name::)

# Check out net.result
head(predicted_nn$net.result)
# okay cool. Predictions seem pretty sure. But we want these to be integers
# for later, so let's round them. 
predicted_nn$net.result <- sapply(predicted_nn$net.result,round,digits=0)
# we aren't doing this the dplyr way because you can't mutate over a list. Whatever. 
# sapply applies the function (in this case, round) and any of its arguments (to 0 digits)
# to whatever object you put in to the first argument. 

# Machine learning folks have a name for this table but I can't
# remember what it's called :( 
table(test_data$private, predicted_nn$net.result)
# From here you can establish an accuracy rate; 
# in my example, 
(60 + 160) /(66 + 167) * 100
# but of course your mileage will vary.




# basic plotting is easy via the 
# package "NeuralNetTools" given above:
plotnet(nn, alpha.val=0.8)
# positive weights are black and negative weighst are gray. Size of line indicates
# relative strength of weight. 

# you can do other post-hoc assessments of your neural net:

garson(nn) # this algorithm apparently only works with 1 H layer
lekprofile(nn) # same here  
# but in our case we have too many hidden layers!

# Try re-training the algorithm and see what you get with
# only one hidden layer. Is it as accurate? Is it worth it 
# to reduce complexity in your architecture but to gain
# these insights? 

# let me know how it goes for you! Try re-framing the architecture
# of the hidden layers and see if you can get higher accuracy.

# Once you've done that, try the titanic data set at Kaggle
# and see how accurate you can get there, too!

# The plan is to wait a few weeks then I will try something with clustering
# for my next machine learning post.
# probably k-means or k-modes algorithms, those being the only other ones
# I've ever needed to use. 

# If you want to see k-modes at work in the meantime here's a description
# of a master at his craft. (also he used to babysit one of my classmates
# from undergrad.)
url4<-"https://www.wired.com/2014/01/how-to-hack-okcupid/"
