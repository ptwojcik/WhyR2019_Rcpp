#-----------------------------------------------------------------------#
#                      Speeding up R wih C++ (Rcpp)                     #
#             from the basics to more advanced applications             #
#                                                                       #
#                        WhyR? 2019 conference                          #
#           University of Warsaw, Faculty of Economic Sciences          #
#                                                                       #
#                  Piotr Wójcik, pwojcik@wne.uw.edu.pl                  #
#              Data Science Lab WNE UW, dslab.wne.uw.edu.pl             #
#-----------------------------------------------------------------------#
# # 6. STL, iterators and range-based loops                             #
#-----------------------------------------------------------------------#

# STL - Standard Template Library

# The real strength of C++ is revealed when you need to implement
# more complex algorithms. The standard template library (STL) 
# provides a set of extremely useful data structures and algorithms.

# One of the elements of STL are iterators. They are abstracting
# away the details of the underlying data structure. 

# Iterator is an class used to access elements of
# Vector, DataFrame or List. 

# algorithms provided by STL use iterators to specify 
# location or range of data to apply the algorithms


# Specific iterator type is defined for each data
# structure of Rcpp.

# NumericVector::iterator
# IntegerVector::iterator
# LogicalVector::iterator
# CharacterVector::iterator
# DataFrame::iterator
# List::iterator


# sample references:
# i = a.begin()   - iterator i points at the first element of a
# ++i     - updates i to the state pointing at the NEXT element
# --i     - updates i to the state pointing at the PREVIOUS element
# i + 1   - iterator pointing at the next element AHEAD of i
# i - 1   - iterator pointing at the next element BEHIND of i
# *i      - represents the VALUE of the element pointed by i 
#           and is called a dereference operator
# a.end()   - iterator pointing to the end (ONE AFTER the last element) of a
# *(a.begin() + k)   - the value of the k-th element of a (a[k]).

# please refer to the file: "cpp_files/myMeanCppIterator.cpp"

sourceCpp("cpp_files/myMeanCppIterator.cpp")

# or the function below

cppFunction('double myMeanCppIterator(NumericVector x) {
             double sum = 0;
            
             // we define the iterator over numeric vector x
             for(NumericVector::iterator i = x.begin(); i != x.end(); ++i) {
             // now the value on position i is accessible as *i
               sum += *i;
             }
             return sum/x.size();
             }')

# lets check how it compares to previous 
# approaches from topic 2 

set.seed(987654321)

x <- rnorm(1e6)

benchmark("mean" = mean(x),
          "myMeanR" = myMeanR(x),
          "myMeanCpp" = myMeanCpp(x),
          "myMeanCppIter" = myMeanCppIterator(x),
          order = "relative")[, 1:4]

# this code is not optimal as the x.end() iterator 
# is called in each iteration

# lets try to optimize it by storing 
# it's value as a constant
# If you're not going to (or supposed to)
# modify the value of the object in the code,
# it should be declared by the const command

# we can use auto identifier to automatically
# declare the type of object based on the value
# which is assigned
# this possibility was intdroduced in C++11

# C++ 11 was established in 2011 and introduced
# new functionalities and notations. 
# Many new features have been added to make
# C++ even easier to learn for beginners.

# C++11 availability has to be 
# activated for use with Rcpp
# by adding [[Rcpp::plugins(cpp11)]].

# this is done in the file:
# "cpp_files/myMeanCppIterator2.cpp"

sourceCpp("cpp_files/myMeanCppIterator2.cpp")

# or in the code below

cppFunction(plugins = c("cpp11"),
            'double myMeanCppIterator2(NumericVector x) {
             double sum = 0;
             // using auto identifier and const
             // to define a constant
             const auto x_end = x.end();
            
            // we define the iterator over numeric vector x
            for(NumericVector::iterator i = x.begin(); i != x_end; ++i) {
            // now the value on position i is accessible as *i
               sum += *i;
             }
            return sum/x.size();
            }')

# and compare again

benchmark("mean" = mean(x),
          "myMeanR" = myMeanR(x),
          "myMeanCpp" = myMeanCpp(x),
          "myMeanCppIter" = myMeanCppIterator(x),
          "myMeanCppIter2" = myMeanCppIterator2(x),
          order = "relative")[, 1:4]

# now it is much better

# This code can be further simplified through 
# the use of another C++11 feature: 
# range-based for loops. 

# check the file "cpp_files/myMeanCppRangeBasedLoop.cpp"

sourceCpp("cpp_files/myMeanCppRangeBasedLoop.cpp")

# or the code below

cppFunction(plugins = c("cpp11"),
   'double myMeanCppRangeBasedLoop(NumericVector x)  {
       double sum = 0;
     // loop definition very similar to R
     for(const auto x_val : x) {
       sum += x_val;
     }
     return sum/x.size();
   }')

# a comparison once again (lets skip myMeanR)

benchmark("mean" = mean(x),
          "myMeanCpp" = myMeanCpp(x),
          "myMeanCppIter" = myMeanCppIterator(x),
          "myMeanCppIter2" = myMeanCppIterator2(x),
          "myMeanCppRangeBasedLoop" = myMeanCppRangeBasedLoop(x),
          order = "relative",
          replications = 1000)[, 1:4]

# code is very efficient and looks simple


# Iterators also allow us to use the C++ equivalents 
# of the apply family of functions. 

# For example, we could again rewrite sum to use
# the std::accumulate function, which takes an starting
# and ending iterator and adds all the values in between. 
# To use accumulate we need to include the <numeric> header.

sourceCpp("cpp_files/myMeanCppIter3accum.cpp")

myMeanCppIter3accum(x)

# The algorithms library defines functions 
# for a variety of purposes (e.g. searching, 
# sorting, counting, manipulating) that
# operate on ranges of elements. 

# algorithms available for iterators can be checked here:
# https://en.cppreference.com/w/cpp/algorithm
# http://www.cplusplus.com/reference/algorithm/

# lets check another example that uses 
# algorithms: std::fill() and std::inner_product

sourceCpp("cpp_files/myMeanCppIter4inner.cpp")

myMeanCppIter4inner(x)


# The STL provides also a large set of 
# data structures which is not covered here

# for more details see: 
# https://en.cppreference.com/w/cpp/container
# https://teuder.github.io/rcpp4everyone_en/280_iterator.html
# https://adv-r.hadley.nz/rcpp.html


#-----------------------------------------------
# Exercises 6.

# Exercise 6.1
# write a function summaryCpp() using STL approach
# that will return: min, max, mean, median, n
# compare its efficiency with a default summary()
# and a function using Rcpp sugar.




# Exercise 6.2
# Rewrite the function colCVsCpp() - see
# part 2 or 3, using iterators.
# Compare their efficiency.




# Exercise 6.3
# Rewrite the function colCVsCpp() - see
# part 2 or 3, using range-based loops
# Compare their efficiency.




# Exercises 6.4(*)
# Using STL write a function that applies
# the Sieve of Erastosthenes algorithm
# to find all prime numbers lower than n,
# where n is the only (integer) input
# check the pseudo code on:
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes




