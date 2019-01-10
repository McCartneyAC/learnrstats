# Lesson Sixteen: Scraping Twitter, Sentiment Analysis, TF-IDF, Geography


# Hi friends, hope you all had a good holiday break. Those of you going into a new semester of school, good luck! Please post your interesting R-related coursework or results so we can all share in your glory and analyses. 

# This next lesson is a bit more on the data science side of R than the social science side. I'm a bit outside my ken! But I've used twitter-scraping a bit to collect data for personal side projects, and sentiment analysis and text analysis can be a lot of fun. Let's dig in!

# The goal of this lesson is to learn how to collect data from twitter posts and to do a little bit of basic visualization on those data, as needed. We'll do some sentiment analysis of some tweets and then we'll break the tweets up into groups and do tf-idf analysis on those groups. 


# But first! 

# the most up-to-date package for scraping tweets into R is the rtweet package:
# devtools::install_github("mkearney/rtweet")
library(rtweet)
# we'll also be using:
# install.packages("httpuv") 
library(httpuv)
library(tidytext)
library(stringr)
library(ggthemes)
library(lubridate)
library(rvest)
library(tidyverse)
# geography: 
library(fiftystater)
library(sf)
library(geosphere)

# to connect to the twitter API, you'll need to make an account for your API connection. There are instructions for this here:

url2 <- "https://towardsdatascience.com/access-data-from-twitter-api-using-r-and-or-python-b8ac342d3efe"

# NOTE: TWITTER CHANGED THEIR SYSTEM JULY 2018
# if you've last done this before then, you're out of date. 

# Once you've done that set-up, you can connect:

## THE NEXT STEP WILL NOT WORK FOR YOU if you have not set up your own 
## twitter developer account and new application. 

# Connect to Twitter's API -------------------------

# if you used rtweet prior to july 2018, re-install it and start over:
create_token(
  app = "learnrstats",
  consumer_key = "t...", #blanking out my codes. Use your own!
  consumer_secret = "...",
  access_token = "1...-J...",
  access_secret = "..."
  )
get_token()

# et voila, we are connected!

# if you have problems with connecting still, try looking at documentation here:
url3 <- "https://rtweet.info/"


# Access Tweets --------------------------------------

# okay, let's scrape some tweets. 

# my recent obsession has been with politics, so I am going to search for "shutdown" which is relevant on today's date (1/9/19)

tweets <- search_tweets(q = "shutdown", n = 10000, include_rts = FALSE)
# original: 4:45 on 1/9/2019 (day following Trump primetime address and after failed 
# Pelosi/Shumer/Trump Meeting)

# or
tweets<-read_csv("shutdown_tweets.csv")


# a check I do based on the original project I used this for. Probably unnecessary:
anyDuplicated(tweets$status_id)

# where are the tweets from? 
tweets %>% 
  group_by(country_code) %>% 
  count()

# hmmm. I don't want tweets from outside the US, but most of mine have NA as their country code. 
# the problem is, this is an "OR" operation (US or NA) and the logical code for NA (is.na(x)) doesn't work super well when combined with other friends, so I'm actually going to manually enter the other countries to eliminate them. eyeroll. 
codes<-c("AU", "BE", "BR", "CA", "CR", "FR", "GB", "JP", "MX", "NL", "NZ", "PT", "SA", "SG",
         "", "AT", "CA", "CN", "IE" )
tweets<-tweets %>% 
  filter(!country_code %in% codes)

tweets %>% 
  group_by(country_code) %>% 
  count()
# cool. 

# the main page for rtweet has some sample code for mapping tweets. 

## create lat/lng variables using all available tweet and profile geo-location data
twts <- lat_lng(tweets) #one of the cooler rtweet functions :) 
twts
# oh this isn't ggplot! this is base R plotting. icky. We'll have to fix this later. 
## plot state boundaries
par(mar = c(0, 0, 0, 0))
maps::map("state", lwd = .25) #changing state to world reveals that one tweet came from Spain but most of these are really in the US. 

## plot lat and lng points onto state map
with(twts, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75)))

#(this is a good time to save the for later. While writing this my computer restarted twice and I lost the original tweet set.)
twts %>% 
  select(status_id, created_at, text, country_code, 
         lat, lng) %>% 
  write_csv(path = "shutdown_tweets.csv")

# this gives me an idea. Are tweets about the shutdown geographically distributed? 
# That is, are tweets nearer to DC more likely to have some kind of quality that tweets further away don't? 
# 
# To investigate this, we'll need some additional packages and methods. See below. 
# 
# For now, let's see what the general quality of the tweets is. 


# I employ the following code *all the time* when using tweets: 
# David Robinson's code for cleaning text into individual words, minus stops
reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
tweet_words <- tweets %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  unnest_tokens(word, text
                #, token = "regex", pattern = reg
                ) %>% 
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]")) 


# now the original tweets list is identical except instead of each line being a unique tweet, each line is a unique word from the original tweet (and all the other data are copied over.)
wp7 <- wesanderson::wes_palette("FantasticFox1", 20, type="continuous") 
# or your own color palette
tweet_words %>%
  filter(word != "shutdown") %>%  # (it's redundant)
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill=word)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() + 
  theme_light()+
  scale_fill_manual(values=wp7)+
  guides(fill=FALSE)+
  labs(title="20 Most frequently used words",
       subtitle="in tweets containing 'Shutdown'")

# Cool. This is an important step not just for its own sake but because it can help us find possible errors in the way we are thinking about and using our data. 

# # Sentiments --------------------

# If you don't know what sentiment analysis is, take some time to go read on it elsewhere. Once again, this post is meant to show you how to use R, not to teach data analysis in general. 
# 
# However, in broad strokes, sentiment analysis characterizes each word in a body of text with a sentiment (either positive or negative, on a scale, or as a factor for a certain emotion. We'll be doing the latter, at least at first. You can use this to track how people are discussing a certain topic (i.e. are they talking about my product positively, and if not, why not?))
# 
# We'll attach a sentiment value to each word in the tweet text corpus, as such: 

nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

nrc

sentimental<-tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(sentiment, sort=TRUE) 
sentimental

wp8 <- wesanderson::wes_palette("FantasticFox1", 10, type="continuous")

ggplot(sentimental, aes(sentiment,n, fill=sentiment))+
  geom_col() + 
  coord_flip() +
  scale_fill_manual(values = wp8) + 
  theme_light()+
  labs( x="Sentiments", subtitle = "January 9, 2019",
        y = "Word Counts", 
        title="Sentiments in tweets containing 'Shutdown'")+
  guides(fill=FALSE)

# huh. the high level of "trust" words is surprising. Let's investigate. 

trust <- tweet_words %>%
  # just the trust words: 
  inner_join(nrc, by = "word") %>% 
  filter(sentiment == "trust")


trust %>% 
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill=word)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() + 
  theme_light()+
  scale_fill_manual(values=wp7)+
  guides(fill=FALSE)+
  labs(title="20 Most frequently used words",
       subtitle="where the sentiment is 'trust'")
# AHHHHHH
# the NRC sentiment library tags the word "President" as a word with "trust" (and, strangely, the color white, which here stands in for the white house. Also Congress)
# 
# So we must excise the word president before seeing what the sentiments of the tweets are. A real problem! 


# Let's get rid of those words that are commonly used with government to get at the real "meat" of what's driving the conversation: 

govlist<-c("president", "congress", "government", "policy", "vote", "trump")
tweet_words <- tweets %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  unnest_tokens(word, text
                #, token = "regex", pattern = reg
  ) %>% 
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]")) %>% 
  filter(!word %in% govlist) 

# (now you can re-run the prior analyses and see how they change when you eliminate these common words.)


# let's look at just the positive and negative words
posneg <- tweet_words %>%
  # just the trust words: 
  inner_join(nrc, by = "word") %>% 
  filter(sentiment %in% c("positive", "negative"))

posneg  %>% 
  group_by(sentiment) %>% 
  count(word, sort = TRUE) %>% 
  head(30) %>% 
  ggplot(aes(fct_reorder(word, n), n, fill=sentiment)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() + 
  theme_light()+
  guides(fill=FALSE) +
  labs(title="30 Most frequently used words",
       subtitle="where the sentiment is 'positive' or 'negative'")

# Cool. 

# 
# I feel like we have a grasp on sentiments like this, but what about a simple positive or negative score? We'll be needing a different sentiment library for that: 

# The AFINN sentiment library gives each word a positive or negative valence score from -5 to 5. I want to predict this score based on geography, so I'm going to join up the wordcount that way. 
# 

afinn <-get_sentiments("afinn")

tweets_afinn <- tweet_words %>% 
  lat_lng() %>% 
  select(status_id, word, lat, lng) %>% 
  inner_join(afinn) %>% 
  filter(!is.na(lat)) %>%
  group_by(status_id) %>% 
  mutate(sentiment = sum(score)) %>% 
  distinct(status_id, .keep_all = TRUE)

tweets_afinn <- tweets_afinn %>% 
  filter(lng < 0) %>% 
  filter(lng > -140)

tweets_afinn
# now we have every tweet, its latitude and longitude, and its sentiment score. Notice that from 10,000 tweets we are now down to 200 or so--that's how few of them enabled location tracking :( 
# 

# Let's plot them geographically:
# `ggmap` used to be the default for this, but since the update to ggplot last fall, `ggmap` is deprecated. 
# 
# There's probably a lesson here about R requiring that you constantly update your skills and awareness, but...


data("fifty_states")
as_tibble(fifty_states)
st_as_sf(fifty_states, coords = c("long", "lat"))
st_as_sf(fifty_states, coords = c("long", "lat")) %>% 
  # convert sets of points to polygons
  group_by(id, piece) %>% 
  summarize(do_union = FALSE) %>%
  st_cast("POLYGON")
# convert fifty_states to an sf data frame
(sf_fifty <- st_as_sf(fifty_states, coords = c("long", "lat")) %>% 
    # convert sets of points to polygons
    group_by(id, piece) %>% 
    summarize(do_union = FALSE) %>%
    st_cast("POLYGON") %>%
    # convert polygons to multipolygons for states with discontinuous regions
    group_by(id) %>%
    summarize())
st_crs(sf_fifty) <- 4326
# (I do this so often I really should make myself a function and put it in my personal package


ggplot(data = sf_fifty) +
  geom_sf() +
  geom_point(data = tweets_afinn,
             aes(y = lat,
                 x = lng,
                 color = sentiment)) +
  labs(
    title = "Relative sentiment of tweets containing the word 'Shutdown'",
    x = "longitude",
    y = "latitude",
    subtitle = "Tweets collected evening of 1/9/19
scored using AFINN sentiment library") + 
  theme_light()

# does distance to D.C. predict sentiment? ---------------------------

# what I want to do is make a linear model that predicts the AFINN sentiment score of these 206 tweets. Ideally, there's a running variable of distance to D.C., where (presumably) the people are most deeply affected by the shutdown. But how do I get that variable? 

# library(geosphere) has our backs!
# it provides the helpful "DistHaversine" function which finds the crow-flies distance from 
# one point to another (but does not take into account the Earth's oblateness)

tweets_afinn <- tweets_afinn %>% 
  mutate(
    distance = distHaversine(
      c(lng, lat), c( -77.009003, 38.889931) # these coordinates are for the Capitol Building
    )
  )
tweets_afinn

# now a simple linear model: 
tweets_afinn %>% 
  lm(sentiment ~ distance, data = .) %>% 
  summary()

# I'm sure we could think of some covariates if we were doing this for real, but alas!

tweets_afinn %>% 
  ggplot(aes(x = distance, y = sentiment)) +
  geom_jitter() + geom_smooth(method = "lm") + 
  theme_light() + labs(
    title = "Linear Model: Shutdown Tweet Sentiment and Distance to DC",
    subtitle = "Are twitter users farther from D.C. more positive about the Shutdown?",
    x = "Distance to The Capitol Building (meters)", 
    y = "AFINN sentiment score of tweet (aggregating all words)"
  )


# Inside and Outside the Beltway
# 
#  one last hypothesis to check!
#  
#  Do those living inside the beltway talk about the shutdown differently than those living outside the beltway?
#  
#  We're going to take our last data set:
tweets_afinn
# and merge it back into a former version of itself. Tricksy, I know. What we want is the original wordlist dataset for every geo-tagged tweet and to add the distance variable back onto it, because we are going to examine its words. 
tweet_dists <- tweets_afinn %>% 
  select(status_id, distance) %>% 
  ungroup() #somehow these were still grouped from before. 

tweet_dists
# cool. 

# revert:
tweet_words <- tweets %>%
filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  unnest_tokens(word, text
                #, token = "regex", pattern = reg
  ) %>% 
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]")) 
tweet_words <- tweet_words %>% 
  select(status_id, word)
tweet_words


word_dists <- tweet_words %>% 
  inner_join(tweet_dists, "status_id")

word_dists

# cool. Now to decide the cutoff. 
# 
# Looking at the map of D.C., I want to be inclusive about what I call "inside the beltway" because many people who work in D.C. live in VA and Maryland. The farthest-out distance of the beltway appears to be near North Springfield Elementary School, the coordinates of which are: 

NSES<-c(38.801815, -77.208172)
# so I will find the haversine distance the same way: 
distHaversine(
  c(38.801815, -77.208172),  # NSES
  c( -77.009003, 38.889931)  # Capitol Building
)
# 14851701
# cool. Anything farther than this is gonna be "outside_beltway" and anything smaller will be "inside_beltway"

word_dists <- word_dists %>% 
  mutate(beltway = case_when(
    distance > 14851701 ~ "outside", 
    distance <= 14851701 ~ "inside"
  ))

# TF-IDF
# TF-IDF is an algorithm that helps us determine what the most characteristic words are in a document  by comparing it to other documents in the corpus. I'm going to compare the document "tweets from inside the beltway" to the document "Tweets from outside the beltway". They'll be differently sized documents but it can't be helped (and probably doesn't matter much). 
# 
tf_idf<-word_dists %>% 
  group_by(word, beltway) %>% 
  count()  %>% 
  bind_tf_idf(word, beltway, n)
# hmmmmmmmm. that's a lot of zero. 
tf_idf %>% 
  group_by(tf_idf) %>% 
  count()
# wow! they're all zero! there was so little data -- or the difference was so nonexistant -- that the tf_idf algorithm failed. I'm sort of at a loss here. I promise this works when you have enough data. 



# anywho, that embarrassing problem aside--let me know if you have any questions. This was just for fun. Good luck to you all. Looking forward to a new lesson next week. 
