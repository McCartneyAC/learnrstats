# Lesson 8: Density Plots, T- Tests, Levene's Test

# one of the things I've heard in passing about IQ data is that 
# the means of the genders are the same--men are equally as smart as women when
# it comes to IQ. However, the variance for men is supposedly greater than the 
# variance for women. I don't know if this is true, but I would like to know. 

# as it happens, I have some IQ data to play with, so we'll use it. 

# we'll be using these packages:
library(psych)
library(tidyverse)

# and we'll need a new one:
install.packages("car")
library(car)

iqdata<-read_csv("http://people.virginia.edu/~acm9q/iq_data.csv")
iqdata


# As it happens, I have some results of some IQ tests, and I've got gender for each
# participant. Here gender = 1 means female and gender = 0 means male. 

# let's take a look at our variables
describe(iqdata)


# what I will start by doing is seeing a density plot of the two 
# groups' iq scores together. By now, ggplot should probably feel pretty
# famililar, but we're calling a new geom_ in this one: geom_density. 
iqdata %>% 
  ggplot(aes(x = iq, color = as.factor(gender))) + 
  geom_density() 

# this kind of sucks, though, becuase we can't tell what 1 and 0 mean for gender
# and even if we could, using blue for girls and pink for boys as the defaults is
# frankly confusing. 

# let's add this: 
iqdata %>% 
  ggplot(aes(x = iq, color = as.factor(gender))) + 
  geom_density() + 
  scale_color_manual(labels = c("male", "female"), values = c("orange", "purple"))

# now we've got orange for boys and purple for girls. 

# but our specific hypotheses are about how the genders relate to each 
# other with respect to IQ. are they the same? Is the variance the same?

# my general instinct is to always go straight to regression, but this is the kind of 
# question that t-tests were made for and so let's do one for example's sake. 

t.test(iqdata$iq ~ iqdata$gender)

# what's the effect size? 
# cohen's d is the difference in means over the pooled sd
cohen_d <- (116.67 - 110.0136)/sd(iqdata$iq)
cohen_d

# the structure here is the same as regression (i.e. in the formula), 
# but it didn't have to be. We can restructure our data to do a t-test differently if
# we want to. If you have a t-test where the data don't group this easily, 
# you'll need to do a t-test like this:

# t.test(group1, group2) 

# but because my data had a grouping variable, I could use a formula.

# so the results show that group 1 (girls) have a higher IQ than group boys by, on average
# 6 points. Weird! (my own analyses show that the test has some small systematic
# biases in favor of girls, but that's irrelevant here)

# what about variances? Is the variance of group 1 equal to the variance of group 2? 

# for that we need levene's test
leveneTest(iq ~ as.factor(gender), data = iqdata)
# note the use of the formula agan. The syntax of all of these should start to feel standard. 

# huh. It looks like the received wisdom doesn't fit the data set. 
# in fact, the variances are ... um... borderline significant?
# not really significantly different? 
# but girls do have a higher iq on this particular nonverbal test. 

# weird. 

# let's take a second graphical approach to this, using boxplots instead:
iqdata %>% 
  ggplot(aes(x = gender, y = iq, color = as.factor(gender))) + 
  geom_boxplot() + 
  scale_color_manual(labels = c("male", "female"), values = c("orange", "purple"))

# notice that we switched the x to y and added y = iq instead
# this fits better with our t-test model above, at any rate. 

# what I dislike about boxplots is that they don't give a sense of the size of the 
# datasets and their distribution. Sometimes I do this:
iqdata %>% 
  ggplot(aes(x = as.factor(gender), y = iq, color = as.factor(gender))) + 
  geom_boxplot() + 
  geom_jitter(width = 0.2, alpha = 0.5) +
  scale_color_manual(labels = c("male", "female"), values = c("orange", "purple")) +
  labs(
    title = "Nonverbal - IQ by gender",
    y = "Nonverbal IQ", 
    x = "",
    color = "Gender"
  )

# to me, this gives a much clearer sense of the nature of the 
# two distributions to each other. 

# note that I also added labels and things to fix the ugliness around the
# chart. One other change I made is to add "alpha = 0.5"
# to the geom_jitter() call. This avoids over-plotting
# of the points so you can get a better sense of 
# precisely how many datapoints there are... which was my
# whole "point" of doing the boxplots this way. 
