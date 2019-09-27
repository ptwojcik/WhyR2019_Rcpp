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
# # 5. Complex input/output objects                                     #
#-----------------------------------------------------------------------#


# R/C++ function may return just a single object

# However sometimes there is a need to return more than one

# The simplest solution in R is to put the objects together
# into a list - which can include objects of different types

#-----------------------------------------------------------------------
# return a list from C++ 

# in part 3. we wrote colCVs function that returned 
# CVs for each column - lets write a function that will return
# not a single vector of CVs, but also particular compoments
# (i.e. means and SDs) for comparison - in a form of a list

# R

colCVsR_list <- function(x) {
  n = nrow(x)
  means_x = colMeans(x)
  means_x2 = colMeans(x**2)
  
  sds = sqrt(n/(n-1) * (means_x2 - means_x**2))

  CVs = 100 * sds/means_x
  
  return(list("means" = means_x,
              "sds" = sds,
              cvs = CVs))
}

# recreate matrix m if needed

set.seed(987654321)

m <- matrix(rnorm(5e5),
            ncol = 10)


colCVsR_list(m)

colCVsR_list(m)$sds

# the C++ equivalent is in the file "cpp_files/colCVsCpp_list.cpp"

sourceCpp("cpp_files/colCVsCpp_list.cpp")

colCVsCpp_list(m)

colCVsCpp_list(m)$sds


# lets compare them

identical(colCVsR_list(m),
          colCVsCpp_list(m))

# each element of the list has to be compared separately

colCVsR_list(m)$means - colCVsCpp_list(m)$means
colCVsR_list(m)$sds - colCVsCpp_list(m)$sds
colCVsR_list(m)$cvs - colCVsCpp_list(m)$cvs

# differences are very small

#-----------------------------------------------------------------------
# return a data frame from C++ 

# as ech of the returned elements has the same length 
# we may decide to return a data.frame instead of a list

# R

colCVsR_df <- function(x) {
  n = nrow(x)
  means_x = colMeans(x)
  means_x2 = colMeans(x**2)
  
  sds = sqrt(n/(n-1) * (means_x2 - means_x**2))
  
  CVs = 100 * sds/means_x
  
  return(data.frame("means" = means_x,
                    "sds" = sds,
                    cvs = CVs))
}

colCVsR_df(m)


# C++

# In Rcpp there is an object DataFrame defined
# which can be created with DataFrame::create()
# One can also use Named() or _[] to specify column names.

# the C++ equivalent is in the file "cpp_files/colCVsCpp_df.cpp"

sourceCpp("cpp_files/colCVsCpp_df.cpp")

colCVsCpp_df(m)

# now all columns can be easily compared

colCVsR_df(m) - colCVsCpp_df(m)

all(abs(colCVsR_df(m) - colCVsCpp_df(m)) < 1e-8)


# CAUTION !!
# When creating a DataFrame with DataFrame::create(), 
# the value of the original Vector element will not be 
# duplicated in the columns of the DataFrame. Instead
# the columns will be the REFERENCE to the original vector. 

# In such case changing the value in the original vector
# will also CHANGE the value in the DataFrame.
# To avoid this, use the clone() function which duplicates
# the values from the ector when creating a DataFrame column.

# to see the example check the file
# "cpp_files/colCVsCpp_dfs.cpp"

sourceCpp("cpp_files/colCVsCpp_df2.cpp")

colCVsCpp_df2(m)



#-----------------------------------------------------------------------
# List as an input to C++ function

# lets remind the mapeR/Cpp() function from part 3
# and assume we want to assess the quality 
# of the linear model based on the result of 
# lm() function.
# Apart from MAPE lets also use other measures

# lets use the mtcars data as an example 

str(mtcars)

model_lm <- lm(mpg ~ ., 
               data = mtcars)

str(model_lm)

class(model_lm)

# lm result is a S3 class which
# in fact this is a list object

# we have all required elements

# real values
model_lm$model$mpg

# fitted values (predictions in the training sample)
model_lm$fitted.values

# and also residuals - their difference (r - p)
model_lm$residuals


all.equal(model_lm$residuals,
          model_lm$model$mpg - model_lm$fitted.values)


# Lets write the R function that operates on real 
# and forecasted values. To avoid checking the name 
# of the outcome variable in the model formula we 
# can calculate real as: real = forecast + residuals 

lmFitMetricsR <- function(model_lm) {
  
  # Lets check if input is an object of class lm(),
  # if not - stop and print an appropriate message
  if (class(model_lm) != "lm") 
    stop("The argument must be a lm() model result.")
  
  forecast = model_lm[["fitted.values"]]
  real = forecast + model_lm[[ "residuals"]]
  # for efficiency lets also store abs(resid)
  # which is used in many formulas
  absresid = abs(real - forecast)
  
  # Mean Square Error
  MSE <- mean(absresid^2)
  # Root Mean Square Error
  RMSE <- sqrt(MSE)
  # Mean Absolute Error
  MAE <- mean(absresid)
  # Mean Absolute Percentage Error
  MAPE <- mean(absresid/real)
  # Adjusted Mean Absolute Percentage Error
  AMAPE <- mean(absresid/(real+forecast))
  # Median Absolute Error
  MedAE <- median(absresid)
  # Mean Logarithmic Absolute Error
  MSLE <- mean((log(1 + real) - log(1 + forecast))^2)
  # Total Sum of Squares
  TSS <- sum((real - mean(real))^2)
  # Explained Sum of Squares
  RSS <- sum((forecast - real)^2)
  # R2
  R2 <- 1 - RSS/TSS
  
  result <- data.frame(MSE, RMSE, MAE, MAPE, 
                       AMAPE, MedAE, MSLE, R2)
  return(result)
}

# check how it works

lmFitMetricsR(model_lm)

lmFitMetricsR(m)

# and compare C++ variant, which is
# in the file "cpp_files/lmFitMetricsCpp.cpp"

sourceCpp("cpp_files/lmFitMetricsCpp.cpp")

# lets check how it works

lmFitMetricsCpp(model_lm)

lmFitMetricsCpp(m)

# compare R and C++ results

all.equal(lmFitMetricsR(model_lm),
          lmFitMetricsCpp(model_lm))

lmFitMetricsR(model_lm) - lmFitMetricsCpp(model_lm)

# CAUTION!
# As with the DataFrame creation, assigning 
# a DataFrame column to vector does not
# copy the column value to vector object, 
# but it will be a “reference” to the column. 
# When the values of vector object are changed,
# the content of the column will also be changed.

# Again, to create a vector by copying the 
# values from the column, clone() function 
# should be used.

# In Rcpp, DataFrame is in fact implemented
# as a vector of vectors. That is why DataFrame 
# has many member functions common to vector, e.g.:
# length(), size() - number of columns
# nrows() - Returns the number of rows
# names()
# fill(v) - fills all the columns of this DataFrame withVector v.
# push_back(v) - add a vector v to the end of the DataFrame
# push_front(x) - add a vector v at the beginning of the DataFrame
# and may others

#-------------------
# S4 objects

# Lets define S4 class "client" in R

setClass("client", # name of the class
         # Defining type of slots
         representation( 
           fname = "character",
           lname = "character",
           occupation = "character",
           age = "numeric",
           married = "logical",
           first_registered = "Date")
         )

# and create a single object of this class

client1 <- new("client",
               fname = "John",
               lname = "Smith",
               occupation = "programmer",
               age = 20,
               married = FALSE,
               first_registered = as.Date("2010-05-01")
               )
client1

# In case of S4 class objects accessing slots
# in C++ is possible via the slot() member function. 
# hasSlot() member function allows to check 
# if the object has a slot with a specific name.

# x.slot("slot_name");
# x.hasSlot("slot_name");

# CAUTION!
# when creating C++ function operating on
# non standard objects - e.g. S4, the declared
# object type should be RObject !!!

cppFunction('int printClientAge(RObject client) {
              if (! client.inherits("client") |
                    ! client.isS4()) 
                  stop("The argument must be an object of S4 class client");
             return(client.slot("age"));
            }')

# lets check how it works 

printClientAge(client1)

printClientAge(m)


# One can also easily create new S4 objects 
# of a specific class

sourceCpp("cpp_files/createS4clientCpp.cpp")

# IMPORTANT!
# the class has to be defined before.
# Rcpp can not define a new S4 class

client2 <- creates4clientCpp("John",
                             "Brown",
                             "soldier", 
                             24,
                             FALSE, 
                             as.Date("2010-05-11"))

client2


#-------------------------------------------------------------
# Exercises 5

# Exercise 5.1
# Write a function compareClientsCpp() that operates
# on two objects of class client and prints information
# if they have the same marital status, ocupation and age
# hint: use "void" as a type of result and Rcout as 
# a printing command, e.g.

cppFunction('void showValue(double x) {
              Rcout << "The value is " << x << std::endl;
              // std::endl stands for end of line
            }')

showValue(1.234567)




# Exercise 5.2
# Write a cpp function basicStatsCpp(df)
# that based on a data frame calculates
# for each column basic statistical measures:
# min, mean, median, n_nonmiss, max, sd, range






