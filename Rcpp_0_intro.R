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
# 0. Introduction and installing required tools                         #
#-----------------------------------------------------------------------#

#-----------------------------------------------------------------------#
# Table of contents

# 0. Introduction and installing required tools
# 1. Writing R functions in C++ - first steps with Rcpp and cppFunction()
# 2. Loops and recursive calls 
# 3. Using Rcpp sugar
# 4. Storing C++ code in  *.cpp files and using sourceCpp()
# 5. STL, iterators, algorithms and range-based loops
# 6. Complex input/output objects
# 7. Interface to other C++ libraries (RcppArmadillo)
#-----------------------------------------------------------------------#


# On this workshop we'll find out how to improve the performance
# of R code by writing selected functions in C++.

# "R is a high-level, expressive language. But that expressivity 
# comes at a price: speed. That’s why incorporating a low-level, 
# compiled language like C or C++ can powerfully complement your 
# R code. While C and C++ often require more lines of code
# (and more careful thought) to solve the same problem, they can
# be orders of magnitude faster than R." H. Wickham "R Packages"


# It may happen that after profiling the R code we find
# bottlenecks and even if we do everything to optimize 
# the R code - it will still be slow.

# Typical bottlenecks of programs in R:
# - loops that can not easily be vectorized, because
#   calculations in a given iteration depend on the 
#   results from the previous iterations
# - recursive functions or problems that require multiple
#   calling the same function

# C++ can help to solve these problems
# C++ is a modern, fast and very well supported 
# programming language with numerous additional 
# libraries allowing to perform various types
# of computational tasks.

# Thanks to the Rcpp package written by Dirk Eddelbuettel
# and Romain Francois combining C++ with R is very easy.

# At the beginning we will discuss the basic aspects 
# of C++ and Rcpp on simple examples that will
# help you easily replace the R code with
# often significantly faster counterparts in C++.

# An earlier knowledge of C++ is NOT required,
# but it will probably be helpful.


#-----------------------------------------------------------------------#
# 0. Installing required tools

# The use of C++ in R requires installation of a C++ compiler.

# To make it available, please:
# - on Windows: install the latest version of Rtools.
# - on Mac: install the Xcode application from the AppStore
# - on Linux: sudo apt-get install r-base-dev or similar.

# one can check if the Rtools are installed with the find_rtools()

if(!require("devtools")) install.packages("devtools")

library(devtools)

devtools::find_rtools()

# if TRUE then installed

# if needed, under Windows Rtools can be installed automatically
# using the install.Rtools() function from the installr package

if(!require("installr")) install.packages("installr")

library(installr)

# WARNING! Even if Rtools were previously installed, 
# running the following command will turn them on 
# in the current R session, which is necessary 
# to use the benefits of Rcpp

install.Rtools()


# lets load the other necessary packages

if(!require("Rcpp")) install.packages("Rcpp")
if(!require("RcppArmadillo")) install.packages("RcppArmadillo")
if(!require("RcppEigen")) install.packages("RcppEigen")
if(!require("RcppNumerical")) install.packages("RcppNumerical")
if(!require("usethis")) install.packages("usethis")
if(!require("rbenchmark")) install.packages("rbenchmark")

library(Rcpp)
library(rbenchmark)
library(usethis)

# setting the working directory (if needed)

setwd("...")


#-----------------------------------------------------------------------#
# Sources and additional materials:

# - official Rcpp website: http://www.rcpp.org/
#  -Rcpp Quickref: http://dirk.eddelbuettel.com/code/rcpp/Rcpp-quickref.pdf
# - Rcpp gallery: http://gallery.rcpp.org/
# - website of Dirk Edelbuettel: http://dirk.eddelbuettel.com/
# - Hadley Wickham "Advanced R": https://adv-r.hadley.nz/rcpp.html
# - Hadley Wickham "R packages": http://r-pkgs.had.co.nz
# - Masaki E. Tsuda "Rcpp for everyone": https://teuder.github.io/rcpp4everyone_en/
# - Colin Gillespie, Robin Lovelace "Efficient R programming":
#         https://csgillespie.github.io/efficientR/rcpp.html
# - Rcpp intro: http://www.mjdenny.com/Rcpp_Intro.html
# - Dirk Eddelbuettel "Seamless R and C++, Integration" (2013)
#      https://github.com/jpneto/Markdowns/blob/master/benchmarking/Eddelbuettel%20-%20Seamless%20R%20and%20C++,%20Integration%20w.Rcpp%20(2013).pdf
# - stackoverflow: https://stackoverflow.com/questions/tagged/rcpp

#-----------------------------------------------------------------------#
# Self-learning of C++

# - http://www.learncpp.com/ 
# - http://www.cplusplus.com/.
# - https://www.sololearn.com/Course/CPlusPlus/

