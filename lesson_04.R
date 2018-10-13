# Lesson Four:  Hello World, Greet, and Fizzbuzz (for loops, if statements)


# in any programming language, the first thing you usually learn to do
# is to print "hello world" so let's get that out of the way:

print("hello world!")

hello <- function() {
  print("hello world!")
}

hello()
# note that some functions just don't need arguments. 
# if the thing you want the function to do never changes, 
# why bother?


# another common first-function is a greeting:

greet <- function(name) {
  print(paste0("hello, ", name))
}


greet("McCartney")

# the paste0 function concatenates two strings. A string is a group of characters strung
# togther. It's a non-numeric data type. "hello" is a string, and so is "McCartney"

# we've already met strings before:
letters

# but note how in that case, each letter of the alphabet is its own string. 


# Fizzbuzz

# fizzbuzz is a perennial programming challenge because
# while it is trivial to do, it requires knowledge of 
# some important fundamentals:
# # if statements
# # functions
# # for loops
# # modular arithmetic
# # printing

# we already know how to declare and run a function and to print a result, so lets sink
# our teeth into if statements and for loops

# if you're a stata user or a user of nearly any other programming language, 
# for loops are pretty simple:

for (i in 1:10){
  print(2*i)
}

# wait a second, isn't that exactly what we got when we did
i <- 1:10
2*i

# yes, it is. The structure of the output is slightly different, in fact slightly less
# useable. If you have a fast sense of time, you may have even noticed that doing the for
# loop was slower. R is a language made for dealing with vectors. In general, if you find
# yourself using a for loop in R, you probably should think of a vector way of doing it. 
# they're faster and they're more in the spirit of how R is meant to work. 

# but for fizzbuzz, we'll use 'em. 

# also notice that the syntax is similar to a function: 
# structure(condition){stuff to do}

# if statements

# if statements have the same stucture:
# if(condition){stuff to do}

if(Sys.Date()=="2018-08-18"){
  print("congrats, you're reading this on the day I wrote it")
} else {
  print("welcome to the github repo. we love it here.")
}

# so many things to notice!

# first, notice that the "condition" part requires a logical test of some kind
# so we'll be using == for equality, != for not equal to, < and >, & and | for these guys.

# second, notice that there's an "else." If the condition is met, the first part 
# happens. If the condition ISN'T met, the "else" part happens. 


# modular arithmetic. 

# let's say it's 1:00 pm and in 38 hours my project is due. I want to know what 
# time of clock that's going to be. 

# clocks use 12 hours cycles-- so they're mod 12

# R does modular arithmetic like this: 

(1 + 38) %% 12

# so it'll be 3 am when my project is due. Gross. 


# putting it all together. 

# we're going to write a fizzbuzz function. 

# fizzbuzz is a game where everyone gets in a circle and counts. If you are a multiple of
# 3, you don't say 3--you say fizz. if you're a multiple of 5, you don't say your number, 
# you say buzz. if you're a multiple of both--fizzbuzz. 

# humans are bad at this game, but computers are very good at it. 

# we're going to make our function so that the argument is how high we want to count. 

# then we are going to print all the fizzbuzzes up to that number. 

fizzbuzz <- function(n) {
  for (i in 1:n) {         # this counts from 1 to n and makes a vector
    if (i %% 15 == 0) {    # we do this in reverse order, starting with 15. why?
      print("fizzbuzz")
    }
    else if (i %% 5 == 0) {  # 'else if' allows us to have more than 2 conditions
      print("buzz")
    }
    else if (i %% 3 == 0) {
      print("fizz")
    }
    else {
      print(i)
    }
  } # hot tip: if you find it a pain to organize your code in neat tabs like this, 
}   # control + shift + A in RStudio will organize it for you. 

fizzbuzz(100)


# whew! we learned a lot today. 

# we learned how to paste together strings
# and of course what a string is
# we said hello to the world and to ourselves
# we learned a new game for summer camp
# we learned about modular arithmetic
# we learned how to make a for loop and why not to bother with it. 
# we learned how to make if/else if /else statements. 

# that's a lot!
