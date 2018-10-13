# Lesson 11: Network Data, Emoji, ggplot2 themes

## Making a Dolphin Social Network

# Recently, I've been learning as much as I can about network data structures and 
# visualization in R. About a year ago, a teacher at our lab's research site dropped 
# a theory about her students and their social networks on me. I know that a professor 
# of mine studied, but never published, a similar theory about five or ten years ago, 
# and I'm dying to take a crack at it. But that means learning to use social networks!

# I took to the #rstats twitter to ask if anyone had any practice with these, and the 
# result here stems from two great guides to which I was directed. 

# # [Doug Ashton's introduction from a London R conference](www.londonr.org/download/?id=97), 
# # which helped me understand the data structures and provided me with the source data for this post. 
# # [Jesse Sadler's Intro to Network Analysis with R](https://www.jessesadler.com/post/network-analysis-with-r/), 
# # which provided the Grammar of Graphics framework and tidyverse-style workflow that I vastly prefer, and 

# Instead of using student social networks, we'll be evaluating the social networks of dolphins, 
# from [D. Lusseau, K. Schneider, O. J. Boisseau, P. Haase, E. Slooten, and S. M. Dawson, 
# Behavioral Ecology and Sociobiology 54, 396-405 (2003)](https://link.springer.com/article/10.1007/s00265-003-0651-y)


## Initial business

# # First, we'll need these packages:
library(tidyverse)
# the tidygraph and ggraph packages are new. you can download them in a single line of code: 
install.packages(c("tidygraph", "ggraph", "emojifont"))
library(tidygraph)
library(ggraph)
library(emojifont)



# And we'll need to read in the data, which Ashton has provided 
# [here on github](https://github.com/dougmet/NetworksWorkshop/tree/master/data).


setwd("V:\\fish_pond_files")
dolphinedges<-read_csv("dolphin_edges.csv")
dolphinvertices<-read_csv("dolphin_vertices.csv")

dolphinedges
dolphinvertices

# First, we'll need to re-structure the data from the current data frames into 
# a graph data frame, which `tidygraph` does in one easy motion:



# Create Network Object
dolphs_tidy <- tbl_graph(nodes = dolphinvertices, edges = dolphinedges, directed = FALSE)
class(dolphs_tidy)


## Build our Fish Pond!
# Now ultimately, we want to visualize the social network. The original paper did much more 
# quantitative analysis and if I examine the classroom dynamics, I'll surely do the same. 
# But mostly I want to visualize a bunch of dolphin social networks, so let's practice editing 
# themes in `ggplot2` to make it happen. What springs to mind for the appropriate theme 
# details for dolphins?


fish_theme <- theme(
  plot.background = element_rect(fill = "#ADD8E6"),
  panel.background = element_rect(fill = FALSE),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.border = element_blank(),
  axis.line = element_blank(),
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  plot.title = element_text(size = 18),
  plot.subtitle = element_text(size = 11),
  plot.caption = element_text(size = 11, hjust = 0),
  legend.position = "bottom",
  legend.background = element_rect(fill = "#ADD8E6"),
  legend.key = element_rect(fill = "#ADD8E6", size = rel(2)),
  legend.text = element_text(size = 11),
  legend.title = element_text(size = 12)
)


# Most of the elements are blank because I found that all the typical 
# axes and tick marks got in the way of the illusion of an ocean. 

# Yes, I know that dolphins aren't fish. 

# What we really need is some way to capture the feeling of 
# what we're researching. Enter ` emojifont `. 


# # But we need dolphin emoji!
emojifont::search_emoji("dolphin")
ggplot() + geom_emoji("dolphin", color = "gray") + fish_theme


# It works! But to get the dolphins into our fish pond, we'll need to do a 
# little bit of magic with the way the `ggraph` and `emojifont` packages interact. 

# Instead of plotting a `geom_node_point()` as `ggraph` would normally have us do, 
# instead we are going to create a network layout and read that into `ggplot` 
# directly. For the layout, I tried a few different algorithms but I think in 
# this case "kk" was the best. 


dolph_layout<-create_layout(dolphs_tidy, layout="kk")
head(dolph_layout, 4)


# Having done this, let's put it all together: 



fishpond <- ggplot(data = dolph_layout) +
  geom_edge_link(alpha = 0.5) +
  geom_emoji(
    "dolphin",
    x = dolph_layout$x,
    y = dolph_layout$y,
    size = 10,
    color = "gray"
  ) +
  geom_node_text(aes(label = Name), repel = TRUE) +
  labs(
    title = "Dolphin Friendships",
    subtitle = "Data from: D. Lusseau, K. Schneider, O. J. Boisseau, P. Haase, E. Slooten, and S. M. Dawson, \nBehavioral Ecology and Sociobiology 54, 396-405 (2003)",
    caption = "Sociogram of the community for groups followed between 1995 and 2001. \nSolid lines are dyads likely to occur more often than expected at P < 0.05 (2-tailed).",
    color = "Gender",
    x = "",
    y = ""
  ) 
fishpond + fish_theme


# There! I could almost go swimming with them!
