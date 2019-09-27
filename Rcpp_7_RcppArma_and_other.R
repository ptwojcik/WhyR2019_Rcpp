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
# 7. Interface to other C++ libraries (e.g. armadillo)                  #
#-----------------------------------------------------------------------#

library(RcppArmadillo)
library(RcppNumerical)
library(rbenchmark)

#-----------------------------------------------------------------------
# Linear regression

# There are numerous ways to estimate 
# a linear regression model in R

# lets use the mtcars data as an example 

str(mtcars)

#-----------------------
# lm()

model_lm <- lm(mpg ~ ., 
               data = mtcars)

summary(model_lm)


# for the sake of simplicity lets concentrate
# just on the coefficients

model_lm$coefficients


#-----------------------
# R function using matrix operations

# beta = (X'X)^(-1)X'y

myLmR <- function(x, y) {
  # solve(x) will return the inverse of matrix x
  beta = solve(t(x) %*% x) %*% t(x) %*% y
  return(beta)
}

model_myLmR <- myLmR(y = mtcars$mpg,
                     x = model.matrix(mpg ~ ., 
                                     data = mtcars)
                     )

model_myLmR

# lets check if the results are the same

summary(abs(model_lm$coefficients - model_myLmR))

#-----------------------
# RcppArmadillo

# RcppArmadillo is R implementation of Armadillo - 
# a C++ library provides vector, matrix and cube types
# (supporting integer, floating point and complex numbers)  
# and a subset of trigonometric and statistical functions.
# e.g. matrix addition, multiplication, various matrix
# factorisations and submatrix manipulation operations are provided

# for more details see:
# https://cran.r-project.org/web/packages/RcppArmadillo/vignettes/RcppArmadillo-intro.pdf

# API Documentation for Armadillo
# http://arma.sourceforge.net/docs.html


# new objects:
# arma::vec, arma::colvec - a column vector
# arma::rowvec - row vector
# arma::mat - matrix


# sample functions:
# statistical functions: - mean, median, stddev, var, etc.
# arma::accu() - accumulate (sum) all elements
# arma::abs()  - obtain magnitude of each element
# arma::cumsum() - cumulative sum
# arma::trans(m) or m.t() - transpose of a matrix
# arma::inv(m) or m.inv() - inverse of a matrix
# arma::solve(x, y) -  solves system xB = y for B
# arma::as_scalar() - convert 1x1 matrix to pure scalar
# arma::diagmat() - generate diagonal matrix from given matrix or vector
# arma::diagvec() - extract specified diagonal
# arma::zeros(), ones() - generate a vector(matrix/cube) of zeroes, ones
# arma::rank()
# arma::norm(x, p)    - computes the p-norm of matrix or vector x
# arma::det(m)  - returns the determinant of a matrix
# arma::svd(m) - performs a singular value decomposition of m

# more details on 
# http://arma.sourceforge.net/docs.html

# lets write a function myLmCppArma()

# you can check the file "cpp_files/myLmCppArma.cpp"

sourceCpp("cpp_files/myLmCppArma.cpp")

# or the code below

cppFunction(depends = "RcppArmadillo",
            'arma::vec myLmCppArma(NumericVector y, NumericMatrix x) {
            
                int n = x.nrow(), k = x.ncol();
            
                // create an Armadillo matrix n x k and fill with FALSE
                arma::mat xa(x.begin(), n, k, false);
                // create an Armadillo column vector for y and fill with FALSE
                arma::colvec ya(y.begin(), y.size(), false);
                // calculate coefficients using: 
                // -  arma::trans for matrix transposition 
                // -  arma::inv for inverting a matrix
                arma::vec coef = arma::inv(arma::trans(xa) * xa) * arma::trans(xa)*ya;
            
                return (coef);
            }')


model_myLmCppArma <-
  myLmCppArma(y = mtcars$mpg,
              x = model.matrix(mpg ~ ., 
                               data = mtcars)
              )

model_myLmCppArma

# lets compare with our benchmark

summary(abs(model_lm$coefficients - model_myLmCppArma))

# another armadillo variant with 
# the solve() function

sourceCpp("cpp_files/myLmCppArma2solve.cpp")

model_myLmCppArma2 <- 
  myLmCppArma2solve(y = mtcars$mpg,
                    x = model.matrix(mpg ~ ., 
                                     data = mtcars)
                    )

model_myLmCppArma2

# lets compare with our benchmark

summary(abs(model_lm$coefficients - model_myLmCppArma2))


# built in fastLM (in armadillo)

model_fastLM <- 
  RcppArmadillo::fastLm(y = mtcars$mpg,
                        X = model.matrix(mpg ~ .,
                                         data = mtcars)
                        )

summary(model_fastLM)

model_fastLM

# lets compare with our benchmark

summary(abs(model_lm$coefficients - model_fastLM$coefficients))


# compare effifciency of all methods

benchmark("lm" = lm(mpg ~ ., data = mtcars),
          "myLmR" = myLmR(y = mtcars$mpg,
                          x = model.matrix(mpg ~ ., 
                                           data = mtcars)),
          "myLmCppArma" = myLmCppArma(y = mtcars$mpg,
                                      x = model.matrix(mpg ~ ., 
                                                       data = mtcars)),
          "myLmCppArma2" = myLmCppArma2solve(y = mtcars$mpg,
                                        x = model.matrix(mpg ~ ., 
                                                         data = mtcars)),
          "fastLM" = RcppArmadillo::fastLm(y = mtcars$mpg,
                                                 X = model.matrix(mpg ~ ., 
                                                                  data = mtcars)),
          replications = 2000, order = "relative")[, 1:4]


# of course fastLM() and lm() calculate
# and return more than just coefficients


#---------------------------------------------------------
# generating random numbers

# Random Walk is a time series process in which
# R_t = R_{t-1} + e_t
# where e_t is a random shock with mean zero

# Many stock prices look like a random walk process


# R function generating a random walk process

randomWalkR <- function(n, seed = 987654321) {
  set.seed(seed)
  e = rnorm(n)
  y = cumsum(e)
  return(y)
}

plot(randomWalkR(100),
     type = "l")

plot(randomWalkR(100, seed = 1234567), 
     type = "l")


# RCppArmadillo functions generating random numbers:

# arma::randu() - generates values from a uniform
#                 distribution in the [0,1] interval
# arma::randn() - generates values from a normal/Gaussian 
#                 distribution with zero mean and 
#                 unit variance

# the seed of the random numbers
# generator can be changed with
# arma_rng::set_seed(value) 
# or arma_rng::set_seed_random() 

# C++ Armadillo version

sourceCpp("cpp_files/randomWalkCppArma.cpp")


plot(randomWalkCppArma(100),
     type = "l")


#-----------------------------------------------------------------------
# Other
# RCppNumerical package has a function fastLR()

# ML libraries based on Rcpp
# - RcppMLPACK based on MLPACK
# - RcppAnnoy - small and lightweight C++ library 
#   for very fast approximate nearest neighbours,
#   originally developed to drive the famous
#   Spotify music discovery algorithm


#---------------------------------------------
# Exercises 7

# Exercise 7.1
# modify the function randomWalkCppArma(n, seed)
# by including an additional parameter distribution
# (with a default value of "norm", but "unif" also possible) 
# and dist_par, that would mean variance for "norm"
# and interval length (symmetric arround 0) for "unif"
# Compare its efficiency with the pure R function.




# Exercise 7.2 
# Write the function baggingLm(x, y, n) that will
# apply the bagging process to the linear regression 
# estimating the model n times on bootstrapped samples
# and storing the coefficients from all iterations 
# in a matrix.
# Return three elements: vector of coefficients
# (averages over n iterations), their standard
# errors (sd(coef)/samp_size) and the matrix 
# with coefficients from all iterations.
# Apply the function on mtcars (for LM).




