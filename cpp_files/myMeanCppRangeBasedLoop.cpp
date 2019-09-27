// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double myMeanCppRangeBasedLoop(NumericVector x)  {
  double sum = 0;
  
  for(const auto x_val : x) {
    sum += x_val;
  }
  return sum/x.size();
}