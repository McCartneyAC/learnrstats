# Lesson Fifteen: R to HTML via Markdown, ggvis, SjPlot

# for today's lesson, we're going to do something a little bit different, which is that we'll be 
# using R-Markdown. The goal of this lesson is to produce a reproducible research document to HTML 
# that can be generated on anyone's machine (provided they have the data).

# to that end, we'll be mainly using these three new packages:
install.packages(c("ggvis", "rmarkdown", "sjPlot", "httr"))

# how to open a page in R Markdown:
# 
# 
# 



# copy this into your new markdown document: 
---
  title: "RMarkdown Practice - Afghanistan 'Hard to Reach'"
author: "Andrew McCartney"
date: "November 30, 2018"
output: 
  html_document:
  df_print: paged
theme: journal
toc: true
toc_depth: 4
toc_float: true
fig_caption: true
code_folding: hide
---
  
  ```{r setup, include=FALSE}
# anything that goes in "setup" will be evaluated when you want it to be, but will never appear in your actual output. As the name implies, this is just the normal preparatory stuff you do before your analysis: load packages, load data, define functions. 
library(ggvis)
library(rmarkdown)
library(sjPlot)
library(dplyr)
library(httr)
library(ggplot2)
library(forcats)
library(extrafont); loadfonts()
url1 <- "https://data.humdata.org/dataset/db1630c9-d0cd-44ba-99a3-e77db9173557/resource/f8d88de0-8972-42b8-9bfc-ac7726701273/download/reach_afg_dataset_ahtra_round2_may2018.xlsx"
httr::GET(url1, write_disk(tf <- tempfile(fileext = ".xlsx")))
reach <- readxl::read_xlsx(tf, 3L)
codebook <- readxl::read_xlsx(tf, 2L)

# this is a function I wrote to fit in to `select_if`. You'll see it later. 
is_extant <-function(x) any(!is.na(x))

# Required for ggvis to work the way we wish
add_title <- function(vis, ..., x_lab = "X units", title = "Plot Title") 
{
  add_axis(vis, "x", title = x_lab) %>% 
    add_axis("x", orient = "top", ticks = 0, title = title,
             properties = axis_props(
               axis = list(stroke = "white"),
               labels = list(fontSize = 0)
             ), ...)
}
```

#Browse the Data

```{r browse}
reach %>% 
  select_if(is_extant) 
```


#Describe the Data

```{r describe, warning = FALSE, message = FALSE}
reach %>% 
  select_if(is_extant) %>%
  psych::describe(fast = TRUE)
```

#Check the Codebook:

We can see all the variables by looking at page 2 of the spreadsheet:
  
  
  ```{r codebook}
codebook %>% 
  select(X__1) %>% 
  select_if(is_extant) 
```



#Plot

##ggplot

We can include regular `ggplot2` plots: 
  
  ```{r plot}
reach_edu <- reach %>% 
  select(tidyselect::vars_select(names(reach), starts_with("Education")))

reach_edu %>% 
  group_by(`Education/What is the main barriers to female student attendance?`) %>% 
  count() %>% 
  rename(val = `Education/What is the main barriers to female student attendance?`) %>% 
  ggplot(aes(y = n, x = fct_reorder(val, n), fill = val)) + 
  geom_col() + 
  coord_flip() + 
  guides(fill = FALSE) + 
  ggsci::scale_fill_uchicago() + 
  labs(
    title = "Why are Afghan children missing school?",
    x = "Reason Given", 
    y = "Count"
  ) + mccrr::theme_andrew(fam = "Dusha V5")
```

##ggvis 

But I also want to show you how nice `ggvis` is. 

`ggvis` is a package developed to be a grammar of *interactive* graphics in the same way that `ggplot2` is a grammar of regular graphics. Unfortunately the project stalled in 2014 and hasn't been taken up by the community, but I hold out hope because, for me at least, it solves some of the problems of `ggplot2`

`ggvis` syntax should look remarkable similar to anyone who is used to `ggplot2`, but with some of the problems of `ggplot` removed and some new quirks to learn. 
```{r ggvis_portion, warning = FALSE, message = FALSE }
reach %>% 
rename(pops =`Demographics/What is the number of total population in your community?` ) %>% 
mutate(pops = as.numeric(pops)) %>% 
ggvis( ~pops) %>% 
layer_histograms() %>% 
add_title(title = "Histogram of Village Populations",
x_lab= "Populations")
```

Huh. Is that... is it poisson distributed? Weird. 

#Models

Finally, let's create a linear model and see what we can do with it in HTML outputs:
  
  Let's predict number of teaching staff by village size. 

```{r modeling, warning = FALSE, message = FALSE }
model1 <- reach %>% 
rename(pops =`Demographics/What is the number of total population in your community?` ) %>%
mutate(pops = as.numeric(pops)) %>% 
rename(tchrs = `Education/What is the estimated number of teaching staff working and giving class in your community?`) %>% 
mutate(tchrs = as.numeric(tchrs)) %>% 
lm(tchrs ~ pops, data = .)

tab_model(model1)
```


Huh. that's weird. Why is there a precise zero estimate for population predicting teacher count? Let's graph with `ggvis` to see what the heck is going on:

```{r plot_model, warning = FALSE, message = FALSE }
reach %>%
rename(pops =`Demographics/What is the number of total population in your community?` ) %>%
mutate(pops = as.numeric(pops)) %>% 
rename(tchrs = `Education/What is the estimated number of teaching staff working and giving class in your community?`) %>% 
mutate(tchrs = as.numeric(tchrs)) %>% 
ggvis(x = ~pops, y = ~tchrs) %>%
layer_points() %>%
layer_model_predictions(model = "lm")


```

Interesting. Although I love the model output given by `sjPlot::tab_model`, maybe it's just a rounding problem? Let's investigate by printing the model summary that base R gives:

```{r model_sum}
summary(model1)
```

Ah yes, it seems that it's a very precise but also a very small significant increase that we are seeing. 

One last bit of advice about outputs into HTML.
``` {r}
print("if you need to print something from R rather than as markdown")
```

```{r}
cat("it's better stylistically to use the cat() function rather than the print() function. Just my two cents. ")

```
