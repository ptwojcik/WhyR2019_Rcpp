#-----------------------------------------------------------------------#
#                     Speeding up R with C++ (Rcpp)                     #
#             from the basics to more advanced applications             #
#                                                                       #
#                        WhyR? 2019 conference                          #
#           University of Warsaw, Faculty of Economic Sciences          #
#                                                                       #
#                  Piotr Wójcik, pwojcik@wne.uw.edu.pl                  #
#              Data Science Lab WNE UW, dslab.wne.uw.edu.pl             #
#-----------------------------------------------------------------------#
# 1. Writing R functions in C++ - first steps with Rcpp                 #
#-----------------------------------------------------------------------#


# cppFunction() function from Rcpp allows you 
# to write functions in C++ inline the R code
# and compile them to be used in R 

# A C++ function is similar to a function in R:
# - it takes a set of input data (function arguments)
# - runs some code on them
# - returns a single object


# There are, however, several important DIFFERENCES
# (which will be also discussed when introduced in examples):

# - in C++ function EVERY command MUST be terminated with a semicolon;
#   (In R, we only use it when we have many instructions on the same line)
# - in C++ function one MUST DECLARE types of objects on which it works,
#   in particular types of function arguments, type of returned value
#   and any intermediate objects that are created inside the function.
# - C++ function MUST have a clear RETURN statement, similar to the R function
#   There may be many return commands in the function, but the function 
#   will exit, when it encounters the first return statement.
# - when creating C++ function we do NOT use the assignment operator.
# - assignment operator in C++ is =. The operator ->, <- is incorrect in C++.
# - comments in C++ will be written as follows:
#    - single-line comment can be created using // ...
#    - multiline comments are created using /*...*/
# - To find the length of a vector in C++, we use the .size() method,
#    which returns an integer.
# - the for() statement has different syntax in C++: 
#   for (init; check; increment).
#   After each iteration we have to increase the value of init 
#   (usually by one),
# - C++ provides operators modifying a value in place, e.g. 
#   i+=1; or just i++; increases the value of i by 1
#   (is equivalent to i = i+1;).
#   Other examples of in place modifying operators: -=, *=, /=.
# - in C++ indexing vectors starts with 0 (similarly to python).
#   Let's write it once again: in C++ INDEXING VECTORS STARTS FROM 0!
#   This is a source of very common errors when converting 
#   functions from R to C++.


# Standard R types of data (integer, numeric, 
# list, etc.) are mapped to corresponding C++ types


# In C++ single values are called "scalars"

# C++ equivalents of individual values
#  (scalars of different types):
# R numeric -> double
# R integer -> int
# R character -> String
# R logical -> bool

# C++ classes for the most popular types of R VECTORS are:
# - NumericVector - vector of numerical values (floating point)
# - IntegerVector - vector of integer values
# - CharacterVector - vector of character (text) values
# - LogicalVector - vector of logical values

# C++ classes for the most popular types of R MATRICES are:
# - NumericMatrix - matrix of numerical values (floating point)
# - IntegerMatrix - matrix of integer values
# - CharacterMatrix - matrix of character (text) values
# - LogicalMatrix - matrix of logical values


# Rcpp also provides wrappers for all other base R
# data types including for example lists and data frames


# Arithmetic operators in C++:
# +
# -
# *
# /
# there is NO operator for power,
# use pow(x, power) instead


# Logical operators in C++ (same as in R):
# | - alternative
# & - conjunction
# ! - negation


#-----------------------------------------------------------------------#
# the first simple example

cppFunction("int squareCpp(int x) {
                int result = x * x;
                // alternative: pow(x, 2);
                return result;
             }")

# of course, it would be more universal to use
# double as input type, but let's see how the function 
# will work for the int (integer) type

# Rcpp will compile the C++ code and create a function that
# will be available in the R workspace

# resulting function cane be used like a normal R function

squareCpp(5)
squareCpp(-12)

# for non-integer numbers it will work too, but 
# it will take of them integer part from them

squareCpp(4.00001)
squareCpp(4.99999)

# lets rewrite the function to operate on all input values

cppFunction("double squareCpp(double x) {
                double result = x * x;
                return result;
             }")

squareCpp(4.00001)
squareCpp(4.99999)


# function cppFunction() is an extension of
# the older the function cxxfunction() from 
# the inline package, but it is much easier to use

# the following examples will show how to build functions
# using Rcpp for sample combinations
# of input types and resulting types

# source/inspiration of below examples:
# https://adv-r.hadley.nz/rcpp.html#rcpp-intro


#-----------------------------------------------------------------------#
# function without input data, 
#  result - single value (scalar)
  
# function without arguments always returning
# integer value of five:

# in R
fiveR <- function() {
  5L
  }

# C++ equivalent
cppFunction('int fiveCpp() {
                return 5;
             }')

# In this simple example, one can see some important differences 
# between R and C++:
# - in C++, we do not use the assignment operator to create functions
# - in C++ one has to declare the type of function result
#    - before the function name
# - in C++ one must use the return statement directly
# - each C++ statement ends with a semicolon;

# the result of both functions will be the same:

fiveR()

fiveCpp()

# lets check if the result is the same

identical(fiveR(), 
          fiveCpp())


#-----------------------------------------------------------------------#
# argument and result are single values (scalars)
  
# lets create a function that returns a sign of a number
# (equivalent to the standard sign() function)
  
# code in R

signR <- function(x) {
  if (x > 0) 1 else 
    if (x == 0) 0 else -1
  }

# let's write it in a way similar to the below C++ code

signR <- function(x) {
  if (x > 0) {
    1
    } else if (x == 0) {
      0
      } else {
        -1
      }
}

# C++ equivalent will look very similar

cppFunction('int signCpp(double x) {
                if (x > 0) {
                    return 1;
                } else if (x == 0) {
                    return 0;
                    } else {
                    return -1;
                    }
             }')

# in the C++ version:
# - we declare the type of each argument and result type 
#    - thanks to this the function is more readable - it 
#    is known what type of argument is required.
# - the syntax of the if() command is IDENTICAL in R and C++
#   C++ also has a while() loop that also works the same as R.
#   As in R, in C++ you can use the break command to exit the loop,
#   but the equivalent of the R command "next" (move to the next iteration)
#   is the "continue" command in C++
# - comparison operator == is identical in C++ and R (similarly !=)

# see how the function works on a set of random values

z <- rnorm(20)

# default R function

sign(z)

# our R function
signR(z)

# as we used if() function inide, the result is based only
# on the first argument of the input vector.
# we will use the function for each value of the vector 
# separately with the help of sapply()

sapply(z, signR)

# the same for signC:

signCpp(z)

# returns an error 

# the function expects a single input value
# - scalar of typ double 

sapply(z, signCpp)

# later today we will see the vectorised 
# version of the Cpp sign() function


# lets create a function that returns 
# a character value "positive", "negative", "zero"


signCharR <- function(x) {
  if (x > 0) {
    "positive"
  } else if (x == 0) {
    "zero"
  } else {
    "negative"
  }
}

# C++ equivalent will again look very similar
# String means a scalar

# CAUTION! if String values are used inside
# C++ code within double quotes "" the cppFunction() 
# argument 'body' sholuld be provided in single quotes ''

cppFunction('String signCharCpp(double x) {
             if (x > 0) {
                 return "positive";
             } else if (x == 0) {
                 return "zero";
                 } else {
                 return "negative";
                 }
             }')

sapply(z, signCharR)

sapply(z, signCharCpp)


all.equal(sapply(z, signCharR),
          sapply(z, signCharCpp))



# functions (both in R and Cpp) might have default values

# R 
timesR <- function(x, n = 2) {
  return(x * n)
}

timesR(10)
timesR(10, 5)


# C++
cppFunction("double timesCpp(double x, 
                             double n = 2) {
                return x * n;
             }")

timesCpp(10)
timesCpp(10, 5)



#-----------------------------------------
# Exercises 1.

# Exercise 1.1
# Write an R and C++ function rootCpp(x, n) that will
# calculate the root of order n (integer) from the value
# of x (double) - hint: use the C++ function pow(x, n) 
# Let the default value of n be 2.
# Apply the function(s) to sample values and compare 
# the results.





# Exercise 1.2
# Write an R and C++ function isOddR/Cpp(n) that will
# a) return TRUE if the integer value n is an odd number 
#    and FALSE otherwise
# b) write a isOddEvenCharR/Cpp(n) function that will 
#    return a string result: "odd" or "even"

# hint: use %% operator in R and % equivalent in C++



