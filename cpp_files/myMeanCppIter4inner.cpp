#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double myMeanCppIter4inner(NumericVector x) {
	// omit missings
	NumericVector x_nonmiss = na_omit(x);
	int n = x_nonmiss.size();
	// create a vector for weights
	NumericVector x_weights(n);
	// fill it with the same value 1.0/n
	// CAUTION!!
	// 1/n would NOT work as 1, 10, 1/10 are all
	// treated as integers and the result of 1/n will be 0
	// 1/double(n) would also work fine
	std::fill(x_weights.begin(), x_weights.end(), 1.0/n);
	
	return std::inner_product(x_nonmiss.begin(), 
                              x_nonmiss.end(), // the first range of values
							  // beginning of the second range
							  x_weights.begin(),
							  // initial value of the product
							  0.0);
}