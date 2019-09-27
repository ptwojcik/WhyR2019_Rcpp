#include <Rcpp.h>
using namespace Rcpp;
#include <numeric>

// [[Rcpp::export]]
double myMeanCppIter3accum(NumericVector x) {
	NumericVector x_nonmiss = na_omit(x);
  return std::accumulate(x_nonmiss.begin(), 
                         x_nonmiss.end(), 
						 // third argument is an initial value
						 // it also determines a data type,
						 // that is why 0.0 used, not 0
						 // (double not int)
						 0.0) / x_nonmiss.size();
}