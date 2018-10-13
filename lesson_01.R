# Lesson One: A basic Workflow

# If you followed along with lesson 0, you've 
# # Downloaded R
# # Downloaded RStudio
# # installed the tidyverse. 

# First we'll be using these two libraries: 
library(psych)
library(tidyverse) # When using the tidyverse, it's best to call it last. I'll explain later.



# Read in our Data

# this step is not usually this messy! but because I wanted this to be
# runnable on anyone's computer, we are using data from a resource online


# I picked these data for their availability and ease of input. 
# this code couldn't handly the messiness of other datasets on 
# winner's site, but that won't matter for you--your data will be 
# a file saved on your computer most likely. 

# Winner's site gives the data on one file and the metadata on another
# so we have to do this in two steps:

# first read in the column names
column_names<-c("nozzel_ratio", "of_ratio", "thrust_coef_vacuum", "thrust_vacuum", "isp_vacuum", "isp_efficiency")

# then read in our data set
# keep the names for things you use here short and meaningful. 
# this is a dataset from nasa experiments, so I'm just gonna call it nasa. 

nasa <- read.table(
  "http://users.stat.ufl.edu/~winner/data/nasa1.dat",
  header = FALSE,
  col.names = column_names
) %>%
  as_tibble()


# A few things to notice 
# I used a function that looks like this %>% 
# That's super weird! We'll learn about what it does later. 
# Also notice that we give something a name by using this arrow: <-
# More on this later also. 

# view your data to make sure it looks right. 
nasa

# I don't know anything about rockets, so let's learn some stuff!

# the dataset is apparently about experiments with rocket cone shapes, 
# which I know from Kerbal Space Program changes the fuel efficiency of 
# the rocket relative to the air pressure around it. 

# let's look at our variables. (This is the function we are using from
# the `psych` package. This step should be familiar to any stata users)

describe(nasa) 



# now let's take a look at the relationship between two variables. 
# I'm picking the fuel/oxidizer ratio as my x variable and the specific impulse of the
# rocket in a vacuum as my y variable. I have no idea ahead of time if these things are related. 

nasa %>%
  ggplot(aes(x = of_ratio, y = isp_vacuum)) +
  geom_point() +
  geom_smooth()
         
# Apparently not related!


# Okay!

# so this example wasn't meant to teach hard skills, but to give you 
# an appetizer of what R does and how we work: 
# # we attach packages
# # we read in our data
# # we examine our variables 
# # we visualize our data
# # (we can also do linear models, machine learning, etc! Those are coming later!) 

# On to lesson 2
