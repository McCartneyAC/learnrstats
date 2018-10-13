# lesson 9: Analyzing an historical experiment.


# for this, we need a new package:
install.packages("MASS")
library(MASS)
library(psych)
library(ggplot2)

data("anorexia")
anorexia

# these data are from: 
# Hand, D. J., Daly, F., McConway, K., Lunn, D. and Ostrowski, E. eds (1993) 
# A Handbook of Small Data Sets. Chapman & Hall, Data set 285 (p. 229)

?anorexia

describe(anorexia)
# looks like we have pre-weight, post-weight, and a tx grouping variable. 
# it would be nice to have data such as treatment offer, intent to treat, demographics, etc. Ah, well. 


# we have 72 participants and three treatment groups

# let's see the balance of the treatment groups
anorexia %>% 
  group_by(Treat) %>% 
  count()

# okay, so 26 pts had the control group, 29 had cognitive bx thx, and 17 had
# family thx. Cool. 

# note that simply pushing the data through that pipeline doesn't 
# change the original data set--it does its manipulations then disappears
anorexia

# the original data are unchanged unless we *ask* them to change. 

# the goal here is to see which therapeutic paradigm had the best impact
# on post-weight of anorexic patients. Presuably we want them to gain weight. 

# there are a few ways to analyze this. My instinct is always to 
# go straight to regression. What would that look like? 

model1<-lm(Postwt ~ Prewt + Treat, data = anorexia)
summary(model1)
# this is kind of annoying, though, because R auto-generates factors
# into dummy variables, and it's decided that CBT is my control group. 
# just because it's alphabetically first. 

# we can make our own dummies:
anorexia <- anorexia %>% 
  mutate(control = if_else(Treat == "Cont", 1, 0 )) %>% 
  mutate(cogbxthx = if_else(Treat == "CBT", 1, 0 )) %>% 
  mutate(familythx = if_else(Treat == "FT", 1, 0 ))

# stop and look. 

# 1) this time the underlying data-frame IS changed, because I asked it to. 
# 2) stop and take note how mutate works with if_else
#     if the condition fits the logical test, a 1 is given, otherwise, a 0
#     this is perfect for assigning dummy variables. 

# let's regress again

model2 <-lm(Postwt ~ Prewt + cogbxthx + familythx, data = anorexia)
summary(model2)
# now we are seeing the real changes of our treatments over the control. 

# we can graph it as such: 

anorexia %>% 
  ggplot(aes(y = Postwt, x = Prewt, color = Treat)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  geom_abline(slope=1, intercept=0)

# note that I've added a line from 0 with a slope of 1
# when the x and y axis are on the same scale, I like to do this to show
# what a point experiencing no change looks like. 

# that way it helps visualize *how well* the two treatment conditions did. 



# my money is on family therapy, personally. 

# let's beautify this plot

install.packages("ggthemes")
library(ggthemes)
anorexia %>% 
  ggplot(aes(y = Postwt, x = Prewt, color = Treat)) +
  geom_point() + 
  geom_smooth(method = "lm") + 
  geom_abline(slope=1, intercept=0) +
  labs(
    title = "Pre- and Post- Weight for Patients with AN",
    subtitle = "Based on therapeutic paradigm",
    x = "Pre-weight",
    y = "Post-weight", 
    color = "Treatment Paradigm", 
    caption = "Data from Hand, D. J., Daly, F., McConway, K., Lunn, D. and Ostrowski, E. eds (1993)"
  ) +
  theme_fivethirtyeight() + 
  scale_color_fivethirtyeight()


# However, this plot isn't *great* because we are really thinking 
# of a pre- and post- condition and a scatterplot doesn't do well for that. 

# what we want is to think about change in weight relative to tx condition

# so let's make a percent change variable. 

anorexia <- anorexia %>% 
  mutate(pct_change = Postwt / Prewt)

anorexia %>% 
  ggplot(aes(y = pct_change, x = Treat, color = Treat)) +
  geom_boxplot() + 
  geom_jitter(alpha = 0.7, width = 0.2)+
  labs(
    title = "Pre- and Post- Weight for Patients with AN",
    subtitle = "Based on therapeutic paradigm",
    x = "Pre-weight",
    y = "Post-weight", 
    color = "Treatment Paradigm", 
    caption = "Data from Hand, D. J., Daly, F., McConway, K., Lunn, D. and Ostrowski, E. eds (1993)"
  ) +
  theme_fivethirtyeight() + 
  scale_color_fivethirtyeight()

# this just *feels* better and it makes it clear that if you wanna
# put back on the lbs, do family therapy instead of CBT. 
