---
title: "Lesson Fifteen: R to HTML via Markdown, ggvis, SjPlot"
subtitle: "RMarkdown Practice - Afghanistan 'Hard to Reach'"
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

## STOP HERE. 
## IF you don't have these in your library already, you may receive errors. Download these packages with:
# install.packages("packagename")
library(ggvis)
library(rmarkdown)
library(sjPlot)
library(dplyr)
library(httr)
library(ggplot2)
library(forcats)
library(extrafont); loadfonts()
library(ggsci)
library(psych)

# we want a dataset available for download here:
url1 <- "https://data.humdata.org/dataset/db1630c9-d0cd-44ba-99a3-e77db9173557/resource/f8d88de0-8972-42b8-9bfc-ac7726701273/download/reach_afg_dataset_ahtra_round2_may2018.xlsx"

#but because it's hidden behind a "download data" button, we have some extra steps: 

# get the url into a better format
httr::GET(url1, write_disk(tf <- tempfile(fileext = ".xlsx")))

# then load that. 
reach <- readxl::read_xlsx(tf, 3L)

# the dataset is three pages of an excel document. Page 3 is the data, but page 2 is the codebook: 
codebook <- readxl::read_xlsx(tf, 2L)

# this is a function I wrote to fit in to `select_if`. You'll see it used later. 
is_extant <-function(x) any(!is.na(x))

# Required for ggvis to work the way we wish
# # this is a handy function from a user on stack-overflow. This kind of thing is necessary because
# # ggvis is no longer under development and they literally didn't get around to making an "add_title"
# # function for the package. Oh how I wish ggvis were still under development! 
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

#Motivation
Sometimes when you're working with R, you need to generate reports of your data. You could write up a nice report in microsoft word or any other kind of editor, copying and pasting R output into it, but that's a huge hassle! R markdown allows you to generate the report in R, then any formatting or numeric changes just change themselves automatically at runtime.

At my job, I need to generate a report on our data collection process 2-3 times per year. When I first started using R, I would do precisely what I just described above: pages and pages of output copied and pasted into word. This last month, I made a reproducible document in R markdown. Now, whenever I need a new report, I just load the data set in and hit "knit" and five minutes later it's done. It took me 40 hours to do that two years ago; now I knock off from work early to write papers. 

#Browse the Data

```{r browse}
# note the general flow of rmarkdown: regular markdown in the document, then an evaluated code chunk, then more markdown, etc. 


reach %>% 
  select_if(is_extant)
# this just calls our function from above: it selects only those variables that have data in them. 
#  in my work site, I'm struggling with lots of datasets that require--for consistency--lots of empty columns for forward compatibility, but it's annoying to have lots of NAs in your output, so this just eliminates them right before they get called. 
```


#Describe the Data

```{r describe, warning = FALSE, message = FALSE}
# Here we call in `describe` from the psych:: package, which is a useful way of looking at your whole data set at a glance. fast = TRUE nixes the skew/kurtosis and a few other less useful elements. 
reach %>% 
  select_if(is_extant) %>%
  psych::describe(fast = TRUE)
```

#Check the Codebook:

We can see all the variables by looking at page 2 of the spreadsheet:


```{r codebook}
codebook %>% 
  select(X__1) # nix everything but the column name variable
```



#Plot

##ggplot

We can include regular `ggplot2` plots: 

```{r plot}
# we can use some cool features from the tidyverse to select only those variables that are in the
# education section of the survey: 
# 
# # it goes like this: 
reach_edu <- reach %>%  # make a new dataset that consists of the old dataset, but:
  select( # select a group of columns 
    tidyselect::vars_select( #that contain variables
      names( #from the list of variable names
        reach), # of the reach data set
      starts_with("Education"))) #that start with the characters "Education"




reach_edu %>% 
  group_by(`Education/What is the main barriers to female student attendance?`) %>% 
  count() %>% 
  rename(val = `Education/What is the main barriers to female student attendance?`) %>% 
  # select the variables I want, count the instances of each element, and then rename it because *ugh*
  ggplot(aes(y = n, x = fct_reorder(val, n), fill = val)) + 
  geom_col() + 
  coord_flip() + 
  guides(fill = FALSE) + 
  ggsci::scale_fill_uchicago() + 
  labs(
    title = "Why are Afghan girls missing school?",
    x = "Reason Given", 
    y = "Count"
  ) + 
  mccrr::theme_andrew(fam = "Dusha V5") +  # nix this section on your version to pick your own theme
  NULL



```

##ggvis 

But I also want to show you how nice `ggvis` is. 

`ggvis` is a package developed to be a grammar of *interactive* graphics in the same way that `ggplot2` is a grammar of regular graphics. Unfortunately the project stalled in 2014 and hasn't been taken up by the community, but I hold out hope because, for me at least, it solves some of the problems of `ggplot2`

The specific benefit here is that in an HTML output, it allows you to resize the graph (<3) and also to download your graph as an svg which makes cleaner results than `ggplot2`.

`ggvis` syntax should look remarkable similar to anyone who is used to `ggplot2`, but with some of the problems of `ggplot` removed and some new quirks to learn. 

```{r ggvis_portion, warning = FALSE, message = FALSE }
reach %>% 
  rename(pops =`Demographics/What is the number of total population in your community?` ) %>% 
  mutate(pops = as.numeric(pops)) %>% # every variable in this dataset is coded as character. Don't know why. 
  ggvis( ~pops) %>% # new quirk: notice the tilde~
  layer_histograms() %>% # "layer" rather than "Geom"
  add_title(title = "Histogram of Village Populations",
            x_lab= "Populations")
```

Is that... is it poisson distributed? Weird. 

#Models

Finally, let's create a linear model and see what we can do with it in HTML outputs:

Let's predict number of teaching staff by village size. I'd expect this to be roughly linear. 

```{r modeling, warning = FALSE, message = FALSE }
model1 <- reach %>% 
  rename(pops =`Demographics/What is the number of total population in your community?` ) %>%
  mutate(pops = as.numeric(pops)) %>% 
  rename(tchrs = `Education/What is the estimated number of teaching staff working and giving class in your community?`) %>% 
    mutate(tchrs = as.numeric(tchrs)) %>% 
  lm(tchrs ~ pops, data = .) # data = . is a way to include a linear model call at the end of a pipe. the . is a "pronoun" that stands in for whatever the output of the prior call is. 

tab_model(model1) #from sjPlot package. I'm in love with this feature. I use it constantly now. 
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
  layer_model_predictions(model = "lm") # an analogue to ggplots "geom_smooth"


```

Interesting. Although I love the model output given by `sjPlot::tab_model`, maybe it's just a rounding problem? Let's investigate by printing the model summary that base R gives:

```{r model_sum}
summary(model1)
```

Ah yes, it seems that it's a very precise but also a very small significant increase that we are seeing. 

#Additional tidbits:

##Printing from R into output:

One last bit of advice about outputs into HTML.
``` {r}
print("if you need to print something from R rather than as markdown")
```

```{r}
cat("it's better stylistically to use the cat() function rather than the print() function. Just my two cents. ")

```


##Tabsetting {.tabset .tabset-fade}

Sometimes you want to tabset within the document, so let's let the user choose which one of those two regression summaries they'd prefer to see. Pay close attention to how the syntax works here: you put an additional bit at the end of the ##header part, and then all the subheaders beneath it become part of the tab until you get back to the original level of your tabbed ##header. 

###sjPlot
```{r }
# summary(model1) 
tab_model(model1)
```

###General Output
```{r }
summary(model1) 
# tab_model(model1)
```

###Anova
just for fun:
```{r }
summary(aov(model1))

```



##End tabset. 
If I think of some more things, I'll add them later. 

I firmly believe that outputting R to HTML is going to be the future of how we deal with R. Rmarkdown documents are just as mobile and useful as general r scripts, but the best outputs are being done into HTML because you eliminate the limitations of the plots or console output, making for cleaner, more professional or sophisticated results. Happy reporting. 

Oh! One more thing: you can (and should!) use rmarkdown to embed shiny apps where appropriate. Google around for the small changes needed to make this happen. However, note that once you go shiny, you can't go back: the entire rmarkdown document needs to be in the shiny reactive paradigm thenceforth, so even static graphs still need to be rendered within a shiny syntax for how that works. You unfortunately can't pick and choose (which is why `ggvis`'s remarkable interactivity wasn't featured in this, because I dislike how shiny works in rmarkdown personally. 
