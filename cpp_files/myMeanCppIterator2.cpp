// [[Rcpp::plugins(cpp11)]]

#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]

double myMeanCppIterator2(NumericVector x) {
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
}