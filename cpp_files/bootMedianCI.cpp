#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector bootMedianCI_Cpp(NumericVector x, 
                               int n, 
							   double clevel = 0.95) {
   NumericVector medians(n);
   int size_x = x.size();
   // repeat sampling n times
   for (int i; i < n; i++) {
	   // sample() function is also in sugar!!
	   // with identical syntax:
	   // sample(Vector x, int size, replace = false)
	   NumericVector bsample_x = sample(x, size_x, true);
       // each time save the median
	   // median() function is also in sugar
	   medians[i] = median(na_omit(bsample_x));
	   }
   // calculate the quantiles in a simplified way
   // using sugar functions 
   int lower = ceil(n * (1- clevel)/2);
   int upper = floor(n * (1 - (1-clevel)/2));
   IntegerVector idx = IntegerVector::create(lower, upper);
   // sorting a numeric vector in place
   // https://gallery.rcpp.org/articles/sorting/
   std::sort(medians.begin(), medians.end());
   NumericVector ci = medians[idx];

   return ci;
}