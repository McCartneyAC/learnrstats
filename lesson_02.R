# Lesson Two: Let's learn some grammar. 

# learning grammar is often the most boring part of any language 
# class. I just want to talk to people! 

# but you can't get very far just memorizing how to say "where is the
# bathroom in this establishment, sir?" so we have to dive into how
# the language works. 

# this will be a very basic overview. 

# Assignment

# Assignment is an operator, just like +, -, *, / are operators
# in math. In R we can assign something two ways. 
x = 8
y <- 9
2*x + y

# However, for many (most?) R users, the <- operator is the preferred one,
# if only becuase it gives the language a bit of its own flair. <- was a common
# operator in the 70s when keyboards had specific arrow keys on them. R kept
# it from that legacy where most modern languages just use =. 
# However, = will have other uses, so to lessen the potential for
# confusion, I will always use <- for assignment. 

# Notice how R acts a bit like your TI graphing calculator from high school. 
# type in a question, get an answer. Rinse, repeat. 

# one of the other uses of the = is to do a logical test. In this case, 
# we double up the = to == to let R know we're asking a logical question. 

2*x + y == 24

2*x + y == 25

# what happens if you try
2x + y == 26

# Why did that fail? 



# we can assign a variable a value like we just did for x and y
# but we can also assign a series of values--a vector--to a variable
# as well. 

# In truth, because R was built for statistics, it treats *everything*
# as vectors. As far as R is concerned, a scalar number is a vector of 
# length 1. 

# one way to get a series of values is to use : 
# so: 

z <- 1:10
z

# We can perform operations over a vector with ease. 
# So say we wanted to list the first 10 even numbers: 

2*z


# The more typical way of getting a vector is to define a list using c()
# I'm not sure what c was originally intended to stand for, but
# I think of it as "collect"

fibonacci<-c(1,1,2,3,5,8,13,21,35,56)
fibonacci + 3
fibonacci * y

# Et Cetera

# I promised last time I would explain this symbol: %>%

# in R, any thing surrounded by % % is an infix operator--it goes
# between its arguments just like + goes between two things you want to add. 
# if you really wanted to, you could do:
+(5,7) # later update: this hasn't been evaluating for some people. I'm on the case. 
# but that just looks wrong. Same thing goes for %>%


# A common one I use is %in%, which comes up if I want to know if a value
# is %in% a range of other values. 

# %>% is special though. It's called the pipe operator, and what it does is 
# take the output of the last thing you did and send it along as the first
# argument of the next thing you want to do. 

# In short, it makes R code easy to read. 

# we could do this two ways: 

# function3(function2(function1(data)))

# or

# data %>% 
#   function1() %>% 
#   function2() %>% 
#   function3()

# the difference in legibility is minimal here, but when your pipeline has 
# 10 or 15 functions in it, the pipe operator becomes priceless.

# so we could do
gauss <- 1:100

sum(gauss)

# or 
gauss %>% 
  sum()



# the $ sign

# The $ tells r where to look to find something. 

# Let's make a silly data frame here. This will have the letters of the English
# alphabet, their capitals, and their position in the alphabet:
lets <- data.frame(lower = letters,
                   caps = LETTERS,
                   position = 1:26)
lets

# let's say I wanted to do an operation on just a *single part* of this dataframe
# I would usually need to use the $ operator to say which part I mean. 

# so my third column is called "position" if I just type 
mean(position)
# R says "I looked and I didn't find anything called position"
# but if I type
mean(lets$position)
# now R knows where to look.

# You may also have noticed that RStudio gave you options near your cursor when you typed
# lets$ to reduce the chance of misspellings. Thanks, RStudio. 

print(caps)
print(lets$caps)

# Easy!

# by the by, the $ "where to look" operator is often ignorable when doing things the tidy way: 
# these should be equivalent: 
print(lets$caps)
lets %>%
  select(caps) %>%
  print()


# Logic

# If you're used to boolean algebra, you may be wondering about symbols for this.
# == tests equality
# != negates
# & is and
# | is or

# my bet, though, is that few of you are here for boolean algebra!
