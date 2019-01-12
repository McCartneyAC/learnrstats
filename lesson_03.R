# Lesson 3: Functions

# R is delightful for its ability to allow you to define your own functions. 
# Excel can do this in a way, but it's a pain in the butt. 
# Stata can also do this but the grammar of its function definition is awful. 

# in R, we define a function like this: 

# name <- function(arguments){
#   what the function does. 
# }

invert<-function(x){
  1/x
}

cube<-function(x){
  x^3
}

power<-function(x, n){
  x^n
}

# Now I've got a whole language for dealing with powers. 
# I can find the inverse of a number:
invert(pi)

# I can cube anything I want:
cube(37)

# And I have a general function deal with powers:
power(27,7)


# Sometimes, your functions require you to do a bit of work more than just one line: 

solve_quadratic_pos<-function(a,b,c){
  det<-sqrt(b^2-4*a*c)
  numerator<-(-b+det)
  denom<-(2*a)
  return(numerator/denom)
}

# so lets say we have a quadratic equation of 
# x^2 + 2*x -15

# we would plug our a,b,c in as arguments:

solve_quadratic_pos(1,2,-15)
# so 3 is one of the roots of the quadratic equation!

# note that I use return() at the end. 
# This isn't strictly necessary, because R will return the result of the function as 
# whatever the last thing it calculated was. 

# Google's R style guide recommends against using return() unless you have to
# but I find that with multi-line functions it helps clear my head 


# postscript:
# for a fully functional quadratic equation solver:
solve_quadratic<-function(a,b,c){
  det<-sqrt(as.complex(b^2-4*a*c))
  numerator<-(-b+det)
  denom<-(2*a)
  pos <- numerator/denom
  numerator<-(-b-det)
  neg <- numerator/denom
  result<-c(pos,neg)
  return(result)
}
