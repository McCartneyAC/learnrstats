# Lesson 13: Data Frame Manipulations with dplyr and reshape2

# Hi everyone, 

# this is one I've been meaning to make for a while, so I'm excited to finally get to it. 

# I don't intend for this to be a comprehensive look at everything that dplyr does that's magical, but
# hopefully you guys can get something out of it nonetheless.

# Frequently when dealing with data, we need to reshape them or manipulate our datasets in some 
# way to get the result we want. The best package for this is dplyr (+ reshape2, a companion package
# in the tidyverse also). Dplyr is an R implementation of SQL data manipulations that are fast, 
# accurate, and easy to understand. 

library(dplyr)

# for today, we're going to use the dataset I was using when I thought of this, but 
# we're going to access it directly from github, as such: 

install.packages("repmis")
library(repmis)
y # yes do whatever you need. 
source_data("https://github.com/McCartneyAC/edlf8360/blob/master/data/jsp.rda?raw=True")

head(jsp)

# this dataset is a group of scores for students nested in schools. 

# first, let's do an easy one: 

jsp %>% 
  filter(School == 1)

# filter allows you to select only the observations that meet some logical test. 

# I sometimes like to do it like this when I have multiple criteria: 

jsp %>% 
  filter(School %in% c(1:5))
# gets me just the observations from the first five schools. 

# what if we only want certain variables?
jsp %>% 
  select(male, School, MathTest0)

# the beauty of the %>% pipe operator is that we can do these back-to-back:
jsp %>% 
  filter(School %in% c(1:5)) %>% 
  select(male, School, MathTest0)

# you can also select *against* observations or variables:
# tonight, my homework required me to do both:
jsp %>% 
  filter(!is.na(MathTest0)) %>% 
  filter(!is.na(male)) %>% 
  filter(!is.na(manual)) %>% 
  filter(!is.na(MathTest2)) %>% 
  select(-Class)

# class was an irrelevant variable, so I nixed it. I also nixed any observation that had 
# missing data for those four variables. Although I am calling variables as arguments 
# in the logical statement, filter only works on observations themselves.

# need to generate a new variable?
# we already know how:

jsp %>% 
  mutate(mean_math = (MathTest0 + MathTest1 + MathTest2)/3) 

# the eagle-eyed among you may have noticed that of the 3 math tests here, if any of the
# three observations were NA, the whole result is NA. This is part of how R operates: anything
# that NA touches becomes NA itself. NA is like a zombie. 

# can you think of a better way to do it? (see below for a hint)

# sometimes, you want to do something to data by groups. dplyr has a powerful tool for this:
?group_by()

jsp %>% 
  group_by(School) %>% 
  mutate(m2_mu = mean(MathTest2, na.rm=T))

# now every school's mean math score on test 2 is available as a data point, so e.g. if you're
# doing something with fixed effects and you want additional precision...

# group_by() has a cool counter, which is ungroup() if you need to group in the middle of a pipe but 
# ... you know, ungroup before the pipe is over. 

# so for example:

jsp %>% 
  group_by(School) %>% 
  mutate(m2_mu = mean(MathTest2, na.rm=T)) %>% 
  ungroup() %>% 
  psych::describe()

# but I've never needed to use this in real life. 

# other goodies:

# eliminate duplicate observations:
jsp %>% 
  distinct()

# rename:
jsp %>% 
  rename("school" = "School") %>% 
  rename("class" = "Class") # stupid data set has capital letter variable names! argh! 

# select by starts_with
jsp %>% 
  select(starts_with("Eng"))
# gets just the English exam scores

# re-order the data frame to put grouping features first:
jsp %>% 
  select(StudentID, Class, School, male, manual, everything())

# sort in order:
jsp %>% 
  arrange(-MathTest2) # who's got the highest score? 

# joins

# joins are super complicated, so I recommend going straight to the source on this one:
hadley<-"http://r4ds.had.co.nz/relational-data.html"


# RESHAPE

# tidy data principles are very opinionated, but they come down to two rules:
# 1) each column is a variable
# 2) each row is an observation
# anything else isn't tidy. 

# in this data set, the math scores are each separate observations... or are they?
# in fact, the data are tidier if I have a column for "score", a column for "subject", 
# and a column for "window" (i.e. 0, 1, or 2) 

# my professor didn't go that far, but it was required to lengthen the data so there's a
# column for just math and just english, and each of the three windows gets its own row. 


# to go completely completely tidy, you can do this:
library(reshape2)
jsp %>% 
  melt()

# but notice how... less than helpful that is in this case. 
# I don't want *every* number to be its own observation, just each of the three
# testing windows. 


# btw, the opposite of melt() is cast(), but it comes in two flavors. 
# generally the flavor we want is 
?dcast() #(see below)
# cast requires some more arguments to be placed because of the additional complexity 
# of casting, but you get the idea. 

# a real example: ----------------------


# I know I've told you guys in the past that data pipelines can get super long... here's a long one. 

# first without annotations--what can you figure out on your own?

# then with annotations. 


# without: 

jsp_long <- jsp %>% 
  # j*m*ny cr*ck*t 
  filter(!is.na(MathTest0)) %>% 
  filter(!is.na(male)) %>% 
  filter(!is.na(manual)) %>% 
  filter(!is.na(MathTest2)) %>% 
  select(-Class) %>% 
  reshape2::melt(id = c("StudentID", "School",  "male", "manual")) %>%
  mutate(window = case_when(
    grepl("0", variable, fixed=TRUE) ~ 0, 
    grepl("1", variable, fixed=TRUE) ~ 1, 
    grepl("2", variable, fixed=TRUE) ~ 2
  )) %>%
  mutate(subject = case_when(
    grepl("Eng", variable, fixed=TRUE) ~ "English",
    grepl("Math", variable, fixed=TRUE) ~ "Maths"
  )) %>% 
  mutate(score = value) %>% 
  select(-variable, -value) %>% 
  reshape2::dcast(StudentID + School + male + manual + window  ~ subject) %>% 
  as_tibble()

# now imagine doing this without the pipe. Start from the bottom and work your way up...
as_tibble(reshape2::dcast(select(mutate(mutate(mutate(reshape2::melt(select(filter(filter(filter(filter(jsp, !is.na(MathTest0)), !is.na(male)), !is.na(manual)), !is.na(MathTest2)), -Class), id = c("StudentID", "School",  "male", "manual")), window = case_when(grepl("0", variable, fixed=TRUE) ~ 0, grepl("1", variable, fixed=TRUE) ~ 1, grepl("2", variable, fixed=TRUE) ~ 2)), subject = case_when(grepl("Eng", variable, fixed=TRUE) ~ "English",grepl("Math", variable, fixed=TRUE) ~ "Maths")), score = value), -variable, -value),StudentID + School + male + manual + window  ~ subject))

# where's the data in there? what happens if you forgot a comma or a parenthesis? 
# if you didn't believe me about the necessity of always coding with pipes, hopefully 
# you do now. 



# with annotations:

jsp_long <- jsp %>% 
  filter(!is.na(MathTest0)) %>% 
  filter(!is.na(male)) %>% 
  filter(!is.na(manual)) %>% 
  filter(!is.na(MathTest2)) %>% 
  # first, my professor only wanted complete observations on these four variables becuase
  # he was later going to make a point about models using missing data for linear mixed effects.
  select(-Class) %>% 
  # I don't need class and it's going to clutter up what I'm about to do later. 
  reshape2::melt(id = c("StudentID", "School",  "male", "manual")) %>%
  # so this lengthens everything that isn't explicitly mentioned as an "id" variable. 
  mutate(window = case_when(
    # case_when is awesome; you can think of it as one call that provides a lot of 
    # "if_else()"s in a row. 
    grepl("0", variable, fixed=TRUE) ~ 0, 
    # unfortunately, I couldn't use dplyr::ends_with() here--it just wouldn't work!
    # so I had to resort to base R. 
    grepl("1", variable, fixed=TRUE) ~ 1, 
    # this says if the number 1 is in the value of an observation, create a new variable
    # and code it as 1. Same for 0 and 2. 
    grepl("2", variable, fixed=TRUE) ~ 2
  )) %>%
  mutate(subject = case_when(
    grepl("Eng", variable, fixed=TRUE) ~ "English",
    grepl("Math", variable, fixed=TRUE) ~ "Maths"
    # this does the same for Eng and Math--new codes in a new varaible. 
  )) %>% 
  mutate(score = value) %>% 
  # recode the variable. I could have used "rename" but I prefer mutate. Same result. 
  select(-variable, -value) %>% 
  # don't need these anymore because I have now encoded their information 
  # elsewhere using mutate. 
  reshape2::dcast(StudentID + School + male + manual + window  ~ subject) %>% 
  # now we lengthen it again, making subject a new variable with value (the missing item here)
  # as its contents, leaving everything on the left-hand-side of the tilde ~ alone. 
  as_tibble()
  # for some reason it was returning the result as a regular R dataframe rather than a tibble, 
  # probably because I had to use non-dplyr stuff in the middle there. 
