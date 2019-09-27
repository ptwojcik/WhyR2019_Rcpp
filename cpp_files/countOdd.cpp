#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
int countOddCpp(int n);
   // sugar function seq(start, end)
   IntegerVector v = seq(1, n);
int sum=0;
for(auto& x : v) {
  sum += x;
}


