# Lesson 7: ANOVA, User Defined Libraries, Mosaic Plots 


# for this lesson, we'll be using a few packages that have been created by users
# in the community. One is an extension to ggplot to allow for the creation of mosaic 
# plots and another is ggpomological, a theme/beautification scheme for ggplots.


devtools::install_github("gadenbuie/ggpomological")
devtools::install_github("haleyjeppson/ggmosaic")
install.packages("HistData")

library(HistData)
library(tidyverse)
library(ggpomological)
library(ggmosaic)



data(Dactyl) # attaches it. 
# it's easy to load your data when it's packaged correctly. 
# this is a dataset of metric foot positions in the Aeneid. 
# an early example of two-way anova. You can learn more about it 
# by doing this: 
?Dactyl



Dactyl

# we can specify and run a two-way anova predicting the count of
# dactyls based on Foot and Line grouping:

anova(lm(count ~ Foot + Lines, data = Dactyl))

# but the real reason I have brought in this data set is to make a fancy picture. 

# this is a more complex example, so let's go through it part by part, then
# look at it again without commentary. 

# I don't want to struggle with fonts in R: use this part --------------------------------------------
# jeez. Neither does anyone else. 

Dactyl %>% 
  # start with the dataset and pipe it into ggplot
  ggplot() +
  # we don't specify aesthetics here, because we'll specify them in the geom_mosaic
  geom_mosaic(aes(
    # because it's a bit finnicky. 
    weight = count,
    # weight is the outcome variable
    x = product(Foot, Lines),
    # the x are the two predictors 
    fill = Foot
    # and we are going to fill each bar by Foot value
    # note that fill takes the place of color for anything that's 
    # a bar rather than a point or a line. Don't ask me why. 
  )) +
  coord_flip() + 
  # this flips the x and y axis. Just makes it more readable with the legends. 
  scale_fill_pomological() + 
  # this uses the colors from the pomological package. 
  labs(
    title = "Dactyl Position in Aeneid Book XI",
    subtitle = "Bar size denotes relative prevalence of Dactyls
    within each group of five lines",
    x = "Line numbers in groups of 5",
    y = "",
    color = "Foot Number:",
    caption = "Edgeworth (1885) took the first 75 lines in
    Book XI of Virgil's Aeneid and classified each of the first
    four 'feet' of the line as a dactyl
    (one long syllable followed by two short ones) or not."
  )  # whew that's a lot of information! 

# without commentary:
Dactyl %>% 
  ggplot() +
  geom_mosaic(aes(
    weight = count,
    x = product(Foot, Lines),
    fill = Foot 
  )) +
  coord_flip() + 
  scale_fill_pomological() + 
  labs(
    title = "Dactyl Position in Aeneid Book XI",
    subtitle = "Bar size denotes relative prevalence of Dactyls
    within each group of five lines",
    x = "Line numbers in groups of 5",
    y = "",
    color = "Foot Number:",
    caption = "Edgeworth (1885) took the first 75 lines in
    Book XI of Virgil's Aeneid and classified each of the first
    four 'feet' of the line as a dactyl
    (one long syllable followed by two short ones) or not."
  )  



# I AM READY FOR A CHALLENGE ---------------------------------------------------

# so to do the next section, you'll need to do some extra work. 
# fonts in R are troublesome even to intermediate R users, though
# some new packages are being developed to help with them. 

# all that is to say that I can only give general instructions and
# you'll need to go into this with a strong sense of being able to
# troubleshoot on your own. 

# this theme uses homemade-apple as a font, so you'll need to install
# it in your system using your normal font-install process to move forward. 

# homemade apple can be found here: 
# https://fonts.google.com/specimen/Homemade+Apple

# download it and install it. 

install.packages("extrafont")
library(extrafont)
font_import()  # then get a cuppa coffee. 
# this will hopefully give you a shot at importing all your system fonts into R.
# but I can't guarantee there won't be random errors no one understands. 

# once you have homemade apple loaded, you can do this: 

paint_pomological(
  # for some reason, you can't pipe into this function, so we'll place
  # it at the top of our normal workflow and leave it open. 
  Dactyl %>%
    # start with the dataset and pipe it into ggplot
    ggplot() +
    # we don't specify aesthetics here, because we'll specify them in the geom_mosaic
    geom_mosaic(aes(
      # because it's a bit finnicky.
      weight = count,
      # weight is the outcome variable
      x = product(Foot, Lines),
      # the x are the two predictors
      fill = Foot
      # and we are going to fill each bar by Foot value
      # note that fill takes the place of color for anything that's
      # a bar rather than a point or a line. Don't ask me why.
    )) +
    coord_flip() +
    # this flips the x and y axis. Just makes it more readable with the legends.
    scale_fill_pomological() +
    # this uses the colors from the pomological package.
    labs(
      title = "Dactyl Position in Aeneid Book X|",
      subtitle = "Bar size denotes relative prevalence of Dactyls
      within each group of five lines",
      x = "Line numbers in groups of 5",
      y = "",
      color = "Foot Number:",
      caption = "Edgeworth (1885) took the first 75 lines in
      Book X| of Virgil's Aeneid and classified each of the first
      four 'feet' of the line as a dactyl
      (one long syllable followed by two short ones) or not."
    ) + # whew that's a lot of information!
    theme_pomological_fancy()
  # this applies the pomological theme. It makes it loook like a painting but it requires
    )
# paint pomological. 



# sans commentary: 
paint_pomological(
  Dactyl %>%
    ggplot() +
    geom_mosaic(aes(
      weight = count,
      x = product(Foot, Lines),
      fill = Foot
    )) +
    coord_flip() +
    scale_fill_pomological() +
    labs(
      title = "Dactyl Position in Aeneid Book X|",
      subtitle = "Bar size denotes relative prevalence of Dactyls
      within each group of five lines",
      x = "Line numbers in groups of 5",
      y = "",
      color = "Foot Number:",
      caption = "Edgeworth (1885) took the first 75 lines in
      Book X| of Virgil's Aeneid and classified each of the first
      four 'feet' of the line as a dactyl
      (one long syllable followed by two short ones) or not."
    ) + 
    theme_pomological_fancy()
 )
