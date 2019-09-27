#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;
using namespace arma;

// [[Rcpp::export]]
arma::vec randomWalkCppArma(int n, 
                                int seed = 987654321) {
  
  arma::vec e, y;
  arma_rng::set_seed(seed);
  
  e = rnorm(n);
  y = cumsum(e);
  return(y);
}
