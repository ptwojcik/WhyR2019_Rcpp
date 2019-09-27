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
# 4. Storing C++ code in  *.cpp files and using sourceCpp()             #
#-----------------------------------------------------------------------#


# Up to now we've created functions in C++ using cppFunction()
# This gives the C++ code presentation simplicity, but in practice 
# it also has disadvantages - eg lack of C++ syntax highlighting, 
# which would make the work easier.

# In practice, to define functions in R using C++ more conveniently
# one can save them in separate files (*.cpp) and compile
# "remotely" using the sourceCpp() function.


# CAUTION!
# to edit *.cpp files one can use RStudio !!!!
# choose File/New File/C++ File
# and look at the example script created
# (it is not saved yet, so there is no .cpp extension)

# we can also look into the file "cpp_files/myMeanNACpp2.cpp"

# In the *.cpp file we have to put several lines of headings:

# #include <Rcpp.h>
# this command gives us access to the Rcpp functions.
# The "Rcpp.h" file contains a list of function and 
# class definitions provided by Rcpp.
# To refer to functions from the Rcpp package we can
# use the syntax: Rcpp::function_name

# using namespace Rcpp;
# this command loads the namespace of the Rcpp package,
# which allows avoid using Rcpp:: when referencing
# to the functions from this package 
#  - just the function_name will be enough

# Above EVERY function that we want to export
# / use in R, we add a tag:
# // [[Rcpp::export]]
# WARNING! space after // is NECESSARY!

# You can also embed the R code in special comment blocks
# inside the *.cpp file


# /*** R
# # This is R code
# */

# It is very convenient if after compiling the function
# and trensfering it to R we want to run the test code.


# lets load functions from the file 

sourceCpp("cpp_files/myMeanNACpp2.cpp")


# apart from compilation of the functions
# the R code at the end of the second 
# function definition was run after
# sending functions to R

myMeanNACpp2(c(1:10, NA))
myMeanNACpp2Sugar(c(1:10, NA))


# the code from the bootMedianCI_Cpp()
# was quite complex and difficult to
# read and check inline

# it is also stored in the 
# "cpp_files/bootMedianCI.cpp" file
# where it i much more readible

# lets check and load it from the file

sourceCpp("cpp_files/bootMedianCI.cpp")


#---------------------------------------------
# Exercises 4


# Create a *.cpp file that will store
# the definitions of the following functions
# - fiboCpp() - from part 2
# - colCVsCpp() - from part 2 or 3
# each in a separate file, add also some R check
# code at the end of these definitions 



