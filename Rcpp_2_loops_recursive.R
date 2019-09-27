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
#  2. Loops and recursive calls                                         #
#-----------------------------------------------------------------------#


#-----------------------------------------------------------------------
# Vector as the function argument and single value (scalar) as a result

# The big difference between R and C++ is that there is time overhead
# of a loop in R is very large, and in C++ much smaller

# lets write the function that calculates the average 
# of the numeric vector (equivalent to the built-in
# mean() function - VERY fast and efficient)

myMeanR = function(x) {
  sum = 0
  n = length(x)
  for(i in 1:n)
    sum = sum + x[i]
  sum/n
}

# C++ equivalent

# The function version in C++ is similar to R, but:
# - in C++ we find the length of the vector using the .size() method
# - the for() loop has a different syntax in C++:
#   for(init; check; increment).
#    - in C++, INDEXING VECTORS STARTS FROM 0!
#    - the loop is initiated by creating an index variable
#      init (in our case: i) with the value 0
#    - before each iteration we check if i<n, and finish the loop,
#      if condition is NOT met.
#    - after each iteration the value of i is increased by 1 using
#      special increment operator i++, which increases the value by 1.
# - i++ is the operator that modifies the value of i "in place":
# - other in place modifying operators: -=, *= and /=
# - for the assignment operation in C++ we use 
#   the equality sign = , not <-

cppFunction('double myMeanCpp(NumericVector x) {
                int i;
                int n = x.size();
                double sum = 0;

                for(i=0; i<n; i++) {
                   sum = sum + x[i];
                }
                return sum/n;
            }')


# the type of the loop indexing variable can be
# also defined directly in the for() command

# summation is now done by the in place modyfing
# operator +=

cppFunction('double myMeanCpp(NumericVector x) {
                int n = x.size();
                double sum = 0;

                for(int i=0; i<n; i++) {
                   sum += x[i];
                }
                return sum/n;
            }')


# The myMeanCpp() function is a good example
# where C++ is much faster than R

# lets compare the calculation speed of myMeanR(), 
# myMeanCpp(), and the built-in R: mean() function

# first we generate a vector of one million random
# values from the normal distribution

x <- rnorm(1e6)

benchmark("mean" = mean(x),
          "myMeanR" = myMeanR(x),
          "myMeanCpp" = myMeanCpp(x)
          )[, 1:4]

# function in C++ is much better than the function in R,
# and even slightly better than the built-in mean() function



#---------------------------------------------------
# matrix as a function argument

# Each vector type has its matrix equivalent:
# - NumericMatrix
# - IntegerMatrix
# - CharacterMatrix
# - LogicalMatrix

# let's write a function that calculates the coefficient 
# of variation (CV = 100 * stdev/mean) for every column
# of a numeric matrix
# (for convenience we will calculate standard deviation 
# (variance) based on the formula: var = mean(x^2) - (mean(x))^2

colCVsR <- function(x) {
  n = nrow(x)
  means_x = colMeans(x)
  means_x2 = colMeans(x**2)

  sds = sqrt(n/(n-1) * (means_x2 - means_x**2) )
  
  CVs = 100 * sds/means_x
  
  return(CVs)
}


# C++ version of the colCVs(x) function

cppFunction('NumericVector colCVsCpp(NumericMatrix x) {
                int nrow = x.nrow(), ncol = x.ncol();
                NumericVector means_x(ncol), means_x2(ncol), 
                              sds(ncol), colCVs(ncol);
            
                for (int j = 0; j < ncol; j++) {
                   // initialize column sum by 0
                   double sum = 0, sum2 = 0;
                   for (int i = 0; i < nrow; i++) {
                       // aggregate x values
                       sum += x(i, j);
                       // calculate also sum of squares
                       sum2 += pow(x(i, j), 2);
                       }
                   means_x[j] = sum/nrow;
                   means_x2[j] = sum2/nrow;
                   sds[j] = sqrt( nrow/(nrow-1) * (means_x2[j] - pow(means_x[j], 2)) );
                   colCVs[j] = 100 * sds[j]/means_x[j];
                   }
               return colCVs;
            }')

# New elements in the above example:
# - in C++, we reference to the element/subset 
#    of a MATRIX with () and not [].
# - in C++, we use the .nrow() and .ncol() methods
#    to get dimensions of the matrix.


# the code is much more complex than in the case of R
# lets compare the time efficiency of both functions

# create a large matrix with 10 columns

set.seed(987654321)

m <- matrix(rnorm(5e5),
            ncol = 10)


colCVsR(m)

# lets compare the sapply approach with the 
# R function CV() defined for a single vector
# to make sure that the results are correct

CV <- function(x) { 100 * sd(x)/mean(x)}

sapply(data.frame(m), CV)

all.equal(colCVsR(data.frame(m)),
          sapply(data.frame(m), CV))


colCVsCpp(m)

# results seem to be different...

identical(colCVsR(m), colCVsCpp(m))

# check the differences

colCVsR(m) - colCVsCpp(m)

# Question to the audience - WHY so large differences?

# where is the mistake in the above C++ code?









# The answer is: the order of terms in the formula for sds:
# sqrt( nrow/(nrow-1) * (means_x2[j] - pow(means_x[j], 2)) );

# as nrow and nrow-1 are integers, C++ treats
# also nrow/(nrow-1) as integer... and
# rounds the ratio down to integer - to 1

# check the following function, where nrow/(nrow-1)
# was removed from the formula (so the multiplier
# of 1 was left)

cppFunction('NumericVector colCVsCpp2(NumericMatrix x) {
                int nrow = x.nrow(), ncol = x.ncol();
                NumericVector means_x(ncol), means_x2(ncol), 
                sds(ncol), colCVs(ncol);
            
                for (int j = 0; j < ncol; j++) {
                   // initialize column sum by 0
                   double sum = 0, sum2 = 0;

                   for (int i = 0; i < nrow; i++) {
                      // aggregate x values
                      sum += x(i, j);
                      // calculate also sum of squares
                      sum2 += pow(x(i, j), 2);
                   }

                   means_x[j] = sum/nrow;
                   means_x2[j] = sum2/nrow;
                   // !!!!!!!!! the difference is just in below line
                   sds[j] = sqrt( (means_x2[j] - pow(means_x[j], 2)) );
                   colCVs[j] = 100 * sds[j]/means_x[j];
                }
                return colCVs;
            }')

# and the result is identical as before

identical(colCVsCpp(m), colCVsCpp2(m))

# the solution here is to put the multiplication
# by nrow/(nrow-1) at the end of the formula:
# sqrt( (means_x2[j] - pow(means_x[j], 2)) * nrow/(nrow-1));
# or request to treat the numerator of the ratio as double 
# by using: ( double (nrow) /(nrow-1))


cppFunction('NumericVector colCVsCpp3(NumericMatrix x) {
                int nrow = x.nrow(), ncol = x.ncol();
                NumericVector means_x(ncol), means_x2(ncol), 
                sds(ncol), colCVs(ncol);
            
                for (int j = 0; j < ncol; j++) {
                   // initialize column sum by 0
                   double sum = 0, sum2 = 0;

                   for (int i = 0; i < nrow; i++) {
                      // aggregate x values
                      sum += x(i, j);
                      // calculate also sum of squares
                      sum2 += pow(x(i, j), 2);
                   }
                   means_x[j] = sum/nrow;
                   means_x2[j] = sum2/nrow;
                   // now the result should be correct
                   sds[j] = sqrt( ( double (nrow) /(nrow-1)) *
                                 (means_x2[j] - pow(means_x[j], 2)) );
                   colCVs[j] = 100 * sds[j]/means_x[j];
                }
                return colCVs;
            }')


colCVsCpp3(m)


colCVsCpp3(m) - colCVsCpp(m)

# Conclusion!
# The order of calculations might have impact 
# on the results in C++ if calculation is done

# But are now the results the same as in R?

identical(colCVsR(m),
          colCVsCpp3(m))

# No! But let's check the difference now

colCVsR(m) - colCVsCpp3(m)

# there are differences, but only on the 9th place
# after the comma which results from the differences 
# in rounding values in R and C++ (precision of storing
# double values) - it's always worth checking when
# converting code between programming languages


all(abs(colCVsR(m) - colCVsCpp3(m)) < 1e-8)


# lets compare the efficiency

benchmark("R" = colCVsR(m),
          "Cpp" = colCVsCpp3(m),
          replications = 1000
          )[,1:4]

#  Cpp variant is several times faster than R



#-----------------------------------------
# example of a function with a recursive call

# Consider the Fibonacci sequence - a sequence of natural numbers
# specified recursively as follows:
# - the first word is equal to 0, the second is equal to 1,
# - each next is the sum of the previous two:

# F(n) = n for n <= 1
#      = F(n-1) + F(n-2) for n > 1

# implementation in R

fiboR <- function(n) {
  if (n <= 1) n else
    fiboR(n-1) + fiboR(n-2)
}

# lets apply the function for the first eleven
# natural numbers

sapply(0:10, fiboR)

# see how the time efficiency changes
# with an increase in the number of recursive calls

benchmark(fiboR(10), 
          fiboR(15), 
          fiboR(20), 
          replications = 500)[, 1:4]

# C++ equivalent

cppFunction('int fiboCpp(int n) {
            if (n <= 1) return(n); else
            return(fiboCpp(n-1) + fiboCpp(n-2)); }')

# lets apply the function for the first eleven
# natural numbers

sapply(0:10, fiboCpp)

# comparison of efficiency between C++ and R

benchmark(fiboR(25), 
          fiboCpp(25))[, 1:4]

# nice acceleration...

# lets check if for C++ function computational 
# complexity grows as fast as in R

benchmark(fiboCpp(10),
          fiboCpp(15),
          fiboCpp(20),
          replications = 10000)[, 1:4]

# NO!!!



#-----------------------------------------
# Exercises 2.


# Exercises 2.1
# Write functions kurtosisR/Cpp(x) that calculate
# kurtosis based on the vector of numeric values
# https://en.wikipedia.org/wiki/Kurtosis
# Compare their time efficiency.




# Exercises 2.2
# Write functions factorialR/Cpp that calculate
# factorial based on an argument being a natural number
# https://en.wikipedia.org/wiki/Factorial
# Compare their time efficiency.




# Exercises 2.3
# A prime number is disible only by 1 and itself.
# Write a function primeR/Cpp checking if a numeric
# input is a prime number.
# https://en.wikipedia.org/wiki/Prime_number
# Compare their time efficiency.




# Exercises 2.4(*)
# Write functions rollMeanR/Cpp(x, n) that based
# on a numeric vector x calculates a rollling mean 
# (mean of previous n observations) and returns
# a vector of the same length as x. For the first
# n-1 observations mean should be based on a shorter
# sample.
# Compare their time efficiency.




