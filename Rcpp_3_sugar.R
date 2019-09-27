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
# 3. Using Rcpp sugar                                                   #
#-----------------------------------------------------------------------#


# Rcpp package provides a lot of syntactic
# “sugar” (code simplification) which make
# the usage of C++ under R very sweet :).

# Rcpp sugar makes it possible to write efficient C++ 
# code that looks ALMOST IDENTICAL as R code.

# Sugar functions aren’t always faster than pure C++,
# but the authors of Rcpp package work on optimising 
# this approach, to make Rcpp coding simpler.


# for example all the basic arithmetic and logical operators 
# are vectorised in Rcpp:
# +, *, -, /, pow, <, <=, >, >=, ==, !=, !

# one can also use summary functions on vectors
# in the same way as they are used in R, e.g.
# sum(v), mean(v), median(v), sd(v), sign(v),
# sqrt(v), pow(v, n) and many others

# for details check useful R-like functions in Rcpp sugar:
# https://teuder.github.io/rcpp4everyone_en/210_rcpp_functions.html#list-of-r-like-functions
# https://thecoatlessprofessor.com/programming/cpp/unofficial-rcpp-api-documentation/#sugar
# https://gallery.rcpp.org/articles/sugar-for-high-level-vector-operations/
# http://dirk.eddelbuettel.com/code/rcpp/Rcpp-sugar.pdf


#-----------------------------------------------------------------------
# Vector as the function argument and its result

# lets remind the squareCpp() function, 
# which was defined for a scalar...

squareCpp(1.234567)

# but cannot be used on a vector of inputs

squareCpp(c(1, 2, 3, 4, 5, 6, 7))

# which is not much useful

# lets write the vector variant of the function

# in pure C++ this would require a loop

cppFunction("NumericVector squareCppVec(NumericVector x) {
                int n = x.size();
                NumericVector result(n);
                for(int i = 0; i < n; i++) { 
                    result[i] = x[i] * x[i]; }

                return result;
             }")

# This function introduces a new element:
# - we create a new numeric vector with the length of n
#   using the constructor: NumericVector result(n);
#   Another convenient way to create a vector is copying
#   an existing vector: NumericVector new = clone(existing).

squareCppVec(c(1, 2, 3, 4, 5, 6, 7))

# this function accepts also scalars 
# (as vectors of length 1)

squareCppVec(1.234567)

# but the code might look more similar to R 
# thanks to Rcpp sugar (multiplication is vectorised)

cppFunction("NumericVector squareCppVec2(NumericVector x) {
                return x * x;
             }")

squareCppVec2(c(1, 2, 3, 4, 5, 6, 7))

# one can also use the vectorized pow(v, n) function
# here we avoid creating intermediate objects

cppFunction("NumericVector squareCppVec3(NumericVector x) {
                return pow(x, 2);
             }")

squareCppVec3(c(1, 2, 3, 4, 5, 6, 7))


benchmark("squareCppVec" = squareCppVec(c(1, 2, 3, 4, 5, 6, 7)),
          "squareCppVec2" = squareCppVec2(c(1, 2, 3, 4, 5, 6, 7)),
          "squareCppVec3" = squareCppVec3(c(1, 2, 3, 4, 5, 6, 7)),
          replications = 50000
          )

# the speed after using sugar is comparable with pure C++


#-----------------------------
# Vector as the function argument and its result
  
# Assume that we have to assess the average
# quality of a forecast for a set of observations
# with a Mean Absolute Percentage Error (MAPE):
# mean [abs(real_i - forecast_i)/real_i]

# lets add also simple error handling as both 
# input vectors should have the same length

# function in R

mapeR <- function(real, forecasts) {
  if (length(real) != length(forecasts)) 
      stop("The length of real and forecasts must be the same.")
  
  mean(abs(real - forecasts)/real)
  }

# C++ with a loop
# stop() - prints an error message and stops execution
# warning() - displays message, but does not stop

cppFunction('double mapeCpp(NumericVector real, NumericVector forecasts) {
                int nf = forecasts.size();
                int nr = real.size();
                if (nf != nr) {
                   stop("The length of real and forecasts must be the same.");
                }
                double mape = 0.0;
                for(int i = 0; i < nf; i++) {
                // use abs for integer and fabs for double values
                   mape += fabs(real[i] - forecasts[i])/real[i];
                }
                return mape/real.size();
            }')


# This function introduces two new elements:
# - if we want to calculate the absolute value
#   in C++ and get the result of class double, 
#   we must use fabs() or std::abs()
#   Using just abs() returns the value of type "int"
#   - rounded to integer!
#   (in C++ there are different functions for 
#   calculating the absolute value for different
#   types of input data)


# sugar version of C++ function as short as possible

cppFunction('double mapeCppSugar(NumericVector real, 
                                 NumericVector forecasts) {
            if ( forecasts.size() != real.size() ) {
               stop("The length of real and forecasts must be the same.");
            }
            return mean(abs(real - forecasts)/real);
            }')


# see how functions work on artificially generated data

set.seed(1234556789)

r <- rnorm(1000) # "real" values

f <- rnorm(1000) # "forecasts"

# lets check if result is the same

mapeR(r, f)
mapeCpp(r, f)
mapeCppSugar(r, f)  

# how it works when the length of vectors differs?

mapeR(r, f[-1])
mapeCpp(r, f[-1])
mapeCppSugar(r, f[-1])  

# comparison of efficiency

benchmark("R" = mapeR(r, f),
          "Cpp" = mapeCpp(r, f),
          "CppSugar" = mapeCppSugar(r, f),
          replications = 50000)[, 1:4]


# not always a function written in C++ will work
# (much) faster than its R equivalent.
# Even if it works several times faster, one needs
# to take into account tha writing a counterpart in C++
# also takes some time.

# In many situations Rcpp sugar allows to make the code
# almost as simple as the pure R code, but not always


# below the colCVsCpp() function in a sugar version

# CAUTION!
# function pow(x, n) and multiplication (*) operate 
# on vectors and cannot be applied on matrices,
# so we need to use one loop inside anyway

cppFunction('NumericVector colCVsCppSugar(NumericMatrix x) {
               int n = x.nrow(), ncol = x.ncol();
               // matrix for squared values of x
               NumericMatrix x2(n, ncol);
               NumericVector means_x(ncol), means_x2(ncol), 
                             sds(ncol), colCVs(ncol);
               // raise all elements of matrix x to power 2
               // loop over columns, but pow() works on vectors now
               for (int j = 0; j < ncol; j++) {
                  // how to refer to a single column/row from a matrix
                  x2( _ , j ) = pow(x( _ , j ), 2);
              }
               // then sugar function colMeans() used
               means_x = colMeans(x);
               means_x2 = colMeans(x2);
               sds = sqrt( double(n)/(n-1) * (means_x2 - pow(means_x, 2.0)));
               colCVs = 100 * sds/means_x;
              
               return(colCVs);
            }')

# new elements:
# refering to the whole column of a matrix: m(_, j)
# refering to the whole row of a matrix: m(i, _)
# colMeans() sugar function

colCVsR(m)
colCVsCpp3(m)
colCVsCppSugar(m)


benchmark("R" = colCVsR(m),
          "Cpp" = colCVsCpp3(m),
          "CppSugar" = colCVsCppSugar(m),
          replications = 100)[,1:4]

# in this case sugar does not seem to be efficient


#-----------------------------------------------------------------------#

# sugar functions also allow to cope with missing values easily

# there are vector functions related to logical values:
# is_na(v), is_nan(v), is_false(v), is_true(v),
# all(v), any(v), ifelse(v, x1, x2)

# lets simulate a vector with missings

set.seed(987654321)

x_val <- rnorm(10)

x_val[c(3, 5, 9)] <- NA

# and check how different function work

mean(x_val)
mean(x_val, na.rm = TRUE)
myMeanCpp(x_val)

# lets write a function calculating the mean
# that deals with missing values

cppFunction('double myMeanNACpp(NumericVector x) {
                int n = x.size(), nonmiss = 0;
                // is_na() is a sugar function, which takes 
                // a numeric vector and returns a logical vector
                LogicalVector x_nonmiss = is_na(x);
                double sum = 0;
  
                for(int i = 0; i < n; i++) {
                   if(!x_nonmiss[i]) {
                      nonmiss++;
                      sum += x[i];
                      }
                   }
               return sum / nonmiss;
             }'
            )

myMeanNACpp(x_val)


# sugar function mean() does not allow 
# to automatically cope with missing values

cppFunction('double myMeanNACppSugar(NumericVector x) {
                return mean(x);
             }'
            )

myMeanNACppSugar(x_val)

# we need to do it using another function in addition

# fortunately there are sugar functions that help
# to cope with NAs and Inf values simply

# na_omit(v), is_finite(v), is_infinite(v),

cppFunction('double myMeanNACppSugar2(NumericVector x) {
                return mean(na_omit(x));
             }'
            )

myMeanNACppSugar2(x_val)



#-----------------------------------------------------
# sampling and bootstrapping

# In many algorithms/applications we need to 
# use random samples 

# this is commonly used in simulations
# (e.g. option pricing in finance),
# assessing chracteristics of parameters
# without known distributions or in small samples

# bootstrapping requires repetitive drawing
# of random samples of the same size as the
# whole dataset/vector (with replacement)
# https://en.wikipedia.org/wiki/Bootstrapping_(statistics)

# you may know it from ML algorithms called
# bagging (bootstrap averaging) where 
# random forest is the most known example

# lets write a function that uses bootstraping
# (with n repetitions) to calculate 95% 
# interval for the median of x


# as there is no built-in function returning
# quantiles in Rcpp we will use a simplified approach 
# - sort the boostrap results in increasing order
# and take observation of index ceiling(n * (1-clevel)/2)
# and floor(n * (1-(1-clevel)/2))


x <- 1:20

# R 

bootMedianCI_R <- function(x, n, clevel = 0.95) {
  medians = array(NA, n)
  size_x = length(x)
  # repeat sampling n times
  for (i in 1:n) {
    bsample_x <- sample(x, size_x, replace = TRUE)
    # each time save the median of the sample
    medians[i] = median(bsample_x, na.rm = TRUE)
  }
  # calculate the quantiles in a simplified way
  lower = ceiling(n * (1- clevel)/2)
  upper = floor(n * (1 - (1-clevel)/2))
  
  medians = sort(medians)
  
  ci = medians[c(lower, upper)]
  # one may also use the quantile function:
  # ci = quantile(medians, c((1-clevel)/2, (1 - (1-clevel)/2)))
  return(ci)
}

bootMedianCI_R(x, 1000)

# C++


cppFunction('NumericVector bootMedianCI_Cpp(NumericVector x, int n, double clevel = 0.95) {
                NumericVector medians(n);
                int size_x = x.size();
                // repeat sampling n times
                for (int i; i < n; i++) {
                   // sample() function is also in sugar!!
                   // with identical syntax as in R:
                   // sample(Vector x, int size, replace = false)
                   NumericVector bsample_x = sample(x, size_x, true);
                   // each time save the median of the sample
                   // median() function is also in sugar
                   medians[i] = median(na_omit(bsample_x));
                }
                // calculate the quantiles in a simplified way
                // using sugar functions 
                int lower = ceil(n * (1- clevel)/2);
                int upper = floor(n * (1 - (1-clevel)/2));
                // If we supply the list of values ::create is used
                IntegerVector idx = IntegerVector::create(lower, upper);
                // sorting a numeric vector in place
                // https://gallery.rcpp.org/articles/sorting/
                std::sort(medians.begin(), medians.end());
                NumericVector ci = medians[idx];

                return ci;
            }')

bootMedianCI_Cpp(x, 1000)


benchmark("bootR" = bootMedianCI_R(x, 1000),
          "bootCpp" = bootMedianCI_Cpp(x, 1000))[, 1:4]
 

# simulations using C++ are almost 50 times faster
# and the code is almost as easy in C++ as in R


#-----------------------------------------------------
# Exercises 3.


# Exercise 3.1
# Write a vector C++ function rootCpp(x, n)
# using Rcpp sugar
# - see exercise 1.1 for comparison




# Exercise 3.2
# Write a version of colCVsCpp() handling
# missing values using Rcpp sugar




# Exercise 3.3
# Using Rcpp sugar write a function any_naCpp(v)
# returning a logical value "true" if a numeric 
# vector (the only input) contains any missings
# and 0 otherwise.




# Exercise 3.4
# Using Rcpp sugar write a function 
# that generates a random walk proces (RW)
# of length being the only parameter:
# in RW: x_i = x_{i-1} + e
# where e is a random disturbance of mean 0
# hint: use rnorm(n) function which generates
# n numbers from a normal distribution N(0,1)




