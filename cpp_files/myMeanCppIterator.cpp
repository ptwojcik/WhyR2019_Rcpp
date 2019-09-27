#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]

double myMeanCppIterator(NumericVector x) {
       double sum = 0;
            
       // we define the iterator over numeric vector x
       for(NumericVector::iterator i = x.begin(); i != x.end(); ++i) {
       // now the value on position i is accessible as *i
          sum += *i;
       }
       return sum/x.size();
}