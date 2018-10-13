# Lesson 10: Using ggplot2 to bring an idea from the ephemera

# Building iteratively toward an idea, 
# or, ggthought2

# in this exercise, we want to show two facts about school
# shootings in the US via a dataset posted by the washington post
# here: 
url<-"https://github.com/washingtonpost/data-school-shootings"

# by now you should be fairly comfortable with downloading, 
# saving, and calling data frame. However, here's a neat trick
# as a thank-you for being patient while I haven't been posting:
paste_data<-function (header = TRUE, ...) {
  require(tibble)
  x <- read.table("clipboard", sep = "\t", header = header, 
                  stringsAsFactors = TRUE, ...)
  as_tibble(x)
}

# After you open the data, you can just copy the excel spreadsheet
# directly then do this:
shootings<-paste_data()
# to get your data frame

# (I think you have to copy only the cells you want; i'm not sure how it would
# react if you, e.g., did control + A then control + C then called this function)

# main packages
library(tidyverse)
library(ggthemes)


# I'm using the colors from RColorbrewer 'Set3' but I want them
# to consistently map to shooting_type across plots, so:


pal0<-c("indiscriminate" = "#BC80BD",
        "targeted" = "#8DD3C7", 
        "accidental" = "#FDB462", 
        "targeted and indiscriminate" = "#80B1D3",
        "unclear" = "#BEBADA", 
        "accidental or targeted" ="#D9D9D9", 
        "public suicide" = "#B3DE69", 
        "public suicide (attempted)" ="#FFFFB3", 
        "hostage suicide" = "#FCCDE5")
# I don't love these colors, but they are good for factors and there are enough of them.         

# initial look:
shootings %>% 
  group_by(shooting_type) %>% 
  count()



# lots of new ggplot2 features we haven't used yet:
shootings %>%
  group_by(year) %>% 
  count(shooting_type) %>% 
  # notice how this makes a new data frame that 
  # lists the number of each shooting type by year (grouping var)
  ggplot(aes(x = year, y = n, fill = fct_reorder(shooting_type, n))) + 
  # what is fct_reorder(variable, n) doing? 
  geom_col(color="black") + 
  coord_flip()+
  scale_fill_manual(values = pal0) +
  labs(
    title = "School Shootings Since Columbine",
    x = "Year",
    y = "Count of Shootings",
    fill = "Shooting Type",
    caption = "Data Via Washington Post"
  ) + 
  scale_x_continuous(breaks=1999:2018) +
  guides(color=FALSE) +
  geom_hline(yintercept = 11.0, color = "black") + 
  geom_hline(yintercept = (11.0 + 3.28), color = "gray") +
  geom_hline(yintercept = (11.0 - 3.28), color = "gray") + 
  annotate("text", x = 1999, y = 11, label = "mean = 11       sd = 3.28")


# to get the bits at the end, I ran this code using
# dplyr::summarise but somehow that's not working now
# and I have no idea why, but here's a more elegant solution:
library(psych)
shootings %>%
  group_by(year) %>% 
  count() %>% 
  describe()

# notice that you don't have to bother to add your margins to the mean
# just make R do that for you :) 

# okay, that shows us that there are roughly 11 school shootings per year 
# and that this is fairly consistent--few if any outliers

# what about casualties?
# (A casualty here is wounded or killed)

shootings %>%
  group_by(year, shooting_type) %>% 
  summarize(n = sum(casualties)) %>% 
  ggplot(aes(x = year, y = n, fill = fct_reorder(shooting_type, n))) + 
  geom_col(color="black") + 
  coord_flip()+
  scale_fill_manual(values = pal0) +
  labs(
    title = "School Shootings Since Columbine",
    x = "Year",
    y = "Count of Casualties",
    fill = "Shooting Type",
    caption = "Data Via Washington Post"
  ) + 
  scale_x_continuous(breaks=1999:2018) +
  # theme_light()+
  guides(color=FALSE) +
  geom_hline(yintercept = 21.4, color = "black") + 
  geom_hline(yintercept = (21.4 + 19.9), color = "gray") +
  geom_hline(yintercept = (21.4 - 19.9), color = "gray") + 
  geom_hline(yintercept = (21.4 + 19.9 + 19.9), color = "gray") + 
  geom_hline(yintercept = (21.4 + 19.9 + 19.9 + 19.9), color = "gray") + 
  annotate("text", x = 2000, y = 21.4, label = "mean = 21.4       sd = 19.9")


# Okay WOW we are in an outlier year and it's only September holy wow. 
# I had to put a few more sd bars in to show how many sigmas we are 
# out of line. Yikes.


# the problem is, this doesn't really show what I want to show, which is 
# * normal amount of shootings, but 
# * abnormal number of casualties. 

# can I put these graphs together somehow in a way that shows both? 

# I actually spent about an hour on just this chart concept. I even drew what I wanted
# on paper at one point. You can maybe see in the final product how my use of 
# graph paper influenced my final result. 


# my first thought was, a numeric result predicted by two
# categorical variables (type, year, count??? you can already see the breakdown)
# the idea was to do two cat vars then facet over time or use gganimate (which 
# I ultimately did for a map .gif, linked in the comments)


# how did it look using ggmosaic?
library(ggmosaic)


# first, we need a dataframe that counts both casualties AND incidents per year.
# when you group_by() and count() with dplyr, you typically lose data in the process, so I 
# did this twice then joined the frames back together (a no-no according to tidy principles).
# if I had listened to the voice in my head saying "this isn't tidy data!" I might have been
# able to predict how and why this wouldn't satisfy my need for a good chart. 
casualties_by_yr_type <- shootings %>%
  group_by(year, shooting_type) %>% 
  summarize(casualties_total = sum(casualties)) 

incidents_by_yr_type <- shootings %>% 
  group_by(year, shooting_type) %>% 
  count()

incidents_and_casualties <- left_join(
  # left_join() is new for us! 
  # it merges two datasets together over a key (e.g. an id variable), so you can
  # use it to add new variables to your extant data from another source. 
  casualties_by_yr_type,                  # first data set
  incidents_by_yr_type,                   #second data set
  by = c(
    "year" = "year",                      # this says match on year
    "shooting_type" = "shooting_type"     # and also on type. you can match on 
                                          # two variables simultaneously!
    )
)


incidents_and_casualties %>% 
  ggplot() + 
  geom_mosaic(
    aes(
      weight = casualties_total,
      x = product(shooting_type, n), 
      fill = shooting_type
    )
  )
# wow. Yikes. that is really illegible. It doesn't show what I wanted it to at all.
# and what exactly is it doing? In essence, the size of each panel is the number of fatalities
# multiplied by the number of shootings that year? that makes zero sense. 


# I bring this up to show how sometimes you're just going to have false
# paths with your R work. It's naiive to take a half-formed idea and just expect
# R to figure it out for you. 

# ------------------------------------------------------

# here's another false path. I wanted to have each shooting be its own 
# rectangle and have that rectangle's size be determined by casualties, then
# subset by year and color by shooting type. 

# but did I know what I was asking R to do?????
incidents_and_casualties %>% 
  ggplot(aes(x = casualties_total, 
             y = n, 
             fill = shooting_type)) + 
  geom_tile()

# This is actually cool because although it doesn't IN ANY WAY
# show what I wanted it to, it shows how indiscriminate killings are more likely
# to have high n of casualties and targeted killings are more common (y axis)
# it *almost* gets across an insight worth having. But it does it in a manner
# that isn't really intuitive or logical. 


# also the bottom left corner is really over-plotted (i.e. there are boxes on top
# of boxes and it isn't immediately clear that that's the case, which means
# data are obscured.)

# so at this point, I got out pen and paper and tried to doodle to myself what I 
# wanted the final project to look like.

# I knew I wanted there to be tiles / boxes and I wanted them to show the severity
# of the shooting, but I also wanted to stack them in groups by year (time trend) 
# while also showing Type. 

# at this point I stopped doodling pictures and wrote:
# "y = incident #
# x = year
# alpha = casualties"

# what did I mean by incident number?
# if we're going to stack them by year, we need a variable to be the y to the x 
# that they're stacking on. What does the stack *indicate?* It indicates
# another shooting--so we need a variable that counts shootings per year
# then assigns each shooting a value that way. 

shootings %>% 
  group_by(year) %>% 
  mutate(mark = row_number()) %>% 
  # this gives each observation a number within its group
  # so the first shooting of 1999 (Columbine) is 1, and the 
  # one that was on the same day but later in the day (yes really) 
  # gets number 2, then the first shooting of the year 2000 rolls us over to 1 again.
  select(year, casualties, shooting_type, mark) %>% 
  # for clarity's sake, I select here only the variables we're going to use.
  # this step is strictly speaking unnecessary, but I find it to be helpful
  # occasionally. The reason is that I want to see the data a bit to help myself
  # troubleshoot any problems down the line, so having only the variables I intend to 
  # use for this plot makes that easier. 
  ggplot(aes(x = year, y = mark, alpha = log(casualties + 0.1), fill = shooting_type)) + 
  # why did I do alpha = log(casualties + 0.1) ? I found that the extreme between
  # incidents with 0 casualties and the incidents with the most (approx 30) was so vast
  # that it made the alpha too "sparse" i.e. there were too many lights squares. 
  # why not just log(casualties)? becuase log(0) is undefined. 
  geom_tile(color = "black") + 
  # makes tiles for each element of the x and y parameters--year and mark
  # argument for color here tells it what to make the borders, which I think was a good
  # aesthetic choice if not necessary for the data. 
  geom_text(label = shootings$casualties, stat = "identity")+
  # this is a fancy trick too--for each shooting, it's # of casualties will be printed 
  # without any statistical adjustment (hence, "identity") in its position on the final
  # figure. I hadn't intended this, but it turns out that these text elements are also
  # susceptible to change via the "alpha = " parameter, so they are darker or lighter 
  # depending on casualties. Not bad, just weird. 
  # if I wanted to change that to have the numbers display regardless of alpha = 0.8, 
  # what would I do? 
  scale_fill_manual(values = pal0) +
  # applies the colors we defined above. 
  scale_x_continuous(breaks=1999:2018) +
  # without this line, it prints only every 5 years or so which annoys me.
  guides(alpha = FALSE) + 
  # we don't need the thing to tell us darker is more casualties, because
  # the number in each box will clue the reader into this. Having two guides on the 
  # right side looks crappy to my eye, but your mileage may vary.
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  # gets rid of axis tick marks, etc, counting up the number of shootings on that axis.
  # it's not bad, it's just annoying to have them there. The final product has the feel of a calendar 
  # almost, so having these here felt wrong somehow. 
  coord_flip() +
  # flip the x and y axes
  labs(
    title = "School Shootings Since Columbine",
    x = "Year",
    y = "",
    fill = "Shooting Type",
    caption = "Data Via Washington Post"
  )


# okay! So it has an equal sized box for each shooting, 
# indicates by color what kind of shooting it was,
# gives a number of casualties, and uses 
# color-darkness to show which incidents were the worst, which naturally draws our eyes 
# to them. 

# I am deeply pleased with this chart, which is why I chose to show it to you all :) 
