#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// in case of using RcppArmadillo the above 
// has to be added to the header

// [[Rcpp::export]]
arma::vec myLmCppArma(NumericVector y, 
                      NumericMatrix x) {
            
    int n = x.nrow(), k = x.ncol();
 
    // create an Armadillo matrix n x k
    // and fill with FALSE
    arma::mat xa(x.begin(), n, k, false);
    // create an Armadillo column vector
    // for y and fill with FALSE
    arma::colvec ya(y.begin(), y.size(), false);
    // calculate coefficients using: 
    // -  arma::trans for matrix transposition 
    // -  arma::inv for inverting a matrix
    arma::vec coef = arma::inv(arma::trans(xa) * xa) *
                     arma::trans(xa)*ya;
            
    return (coef);
   }