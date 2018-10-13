# Lesson 6: graphing.

# in R, there are three main ways to graph things. I'm going to overview
# the first two then really go in depth into the third. 

# libraries
library(lattice)
library(tidyverse)

# first the data. 
# they can be accessed here:
# https://github.com/McCartneyAC/stellae/blob/master/stellae.csv

# download that data, change your working directory, and import it.

setwd("C:\\Users\\andrew\\Desktop")

stellae<-read_csv("stellae.csv")
stellae


# the goal here is to, at least in part, re-create a famous diagram in Astronomy
# the Hertzsrpung-Russell diagram. 

# unfortunately, this dataset doesn't contain luminosity, so we're just gonna use
# mass instead. Shrug. 


# Base R plotting. 
plot(x = stellae$TEFF, y =  stellae$MSTAR)


# plotting with lattice graphics
xyplot(stellae$MSTAR ~ stellae$TEFF)

# gets you essntially the same thing except you 
# reverse x and y, you graph a formula rather than two
# vectors, and you get an extra color. 


# But now we're going to focus on ggplot2, which is the preferred package for 
# graphing nowadays. 
# why didn't I attach library(ggplot2) above? It's already within library(tidyverse)

# How does ggplot work?

# ggplot allows your plot to be built up in pieces. The first such piece is 
# the most important because it tells ggplot what your dataset is and it 
# tells ggplot how your data relate to what you want to graph. 

ggplot(data = stellae)

# wait what just happened? 

# ggplot graphed your plot, but you haven't told it anything other than that we 
# want the data to be the stars.

# now let's give it some 'aesthetic mappings.' This tells ggplot what are variables
# and groups are. 

ggplot(data = stellae, aes(x = TEFF, y =  MSTAR))

# now we've got a ... an empty chart! but we have labeled x and y axes!
# At this point, though, we've already typed a lot more than we typed 
# for base R and it's not even displayed our data yet. How is this better? 

# stay tuned I promise.

# before we go, let's re-write this ggplot as part of a pipeline, which
# cleans our code a little:

stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR))

# same thing as before. Let's add points. 

# notice that as we transition from data to plot, the %>%  operator 
# disappaers in favor of a + 

# Yeah, it's inconsistent, but the writer of the ggplot2 package
# has stated that it can't be fixed without re-writing the entire package from
# the ground up, so we deal with it. 

stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR)) + 
  geom_point()

# there! what else can we add? 

# if we wanted to, we could add a regression line, though it doesn't make sense here:

stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR)) + 
  geom_point() + 
  geom_smooth(method = "lm") #lm for linear model. default is local regression (LOESS)

# that sucked. 

# let's fix something though. In the original HR diagram, the
# x axis (temperature) went from high to low, not low to high. 
stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR)) + 
  geom_point() + 
  scale_x_reverse() 

# Cool. Looking better. Can we add color?
# first we need to map the color quality to a data property
# so we go back to aes() and put color in. 
stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR, color = TEFF)) + 
  geom_point() + 
  scale_x_reverse() + 
  scale_colour_gradient(
    low = "red",
    high = "yellow"
  )

# cool, now they really look like stars.

# actual astronomers will point out that BMV in the data set is 
# the real reference for the apparent color of the star, 
# so why didn't I use it? 
# because it has too many missing data points :( 

# but something is missing... we need a theme. 

stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR, color = TEFF)) + 
  geom_point() + 
  scale_x_reverse() + 
  scale_colour_gradient(
    low = "red",
    high = "yellow"
  ) + 
  theme_dark()

# now let's add labels and remove the color guide: 

stellae %>% 
  ggplot(aes(x = TEFF, y =  MSTAR, color = TEFF)) + 
  geom_point() + 
  scale_x_reverse() + 
  scale_colour_gradient(
    low = "red",
    high = "yellow"
  ) + 
  theme_dark() + 
  labs(
    title = "Temperature and Mass of Stars",
    subtitle = "Stars with known exoplanets",
    x = "Effective Temperature", 
    y = "Solar Masses"
  ) + 
  guides(color = FALSE)


# ggplot may be more *verbose* than base plotting or lattice plotting,
# but the benefits from ease of use and adding changes, not to mention
# dozens and dozens of extensions available, make 
# ggplot2 the real champion for R visualization.

# you probably don't realize it, but you're seeing
# ggplot2-made plots all the time on news sites to display
# data from articles. The theme setting capabilities are such
# that you can't just look at the chart and know how it was made.
# ggplot is infinitely modifiable. 
