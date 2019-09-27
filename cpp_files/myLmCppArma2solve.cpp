#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// [[Rcpp::export]]
arma::vec myLmCppArma2solve(NumericVector y, 
                      NumericMatrix x) {
            
    int n = x.nrow(), k = x.ncol();
 
    // create an Armadillo matrix n x k
    // and fill with FALSE
    arma::mat xa(x.begin(), n, k, false);
    // create an Armadillo column vector
    // for y and fill with FALSE
    arma::colvec ya(y.begin(), y.size(), false);
    // solve(x, y): solves system xB = y for B
    arma::vec coef = arma::solve(xa, ya);
            
    return (coef);
   }