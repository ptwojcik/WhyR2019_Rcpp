#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double myMeanNACpp2(NumericVector x) {
	int n = x.size(), nonmiss = 0;
	// is_na() is a sugar function, which takes 
	// a numeric vector and returns a logical vector
	LogicalVector x_nonmiss = is_na(x);
	double total = 0;
	
	for(int i = 0; i < n; i++) {
		if(!x_nonmiss[i]) {
			nonmiss++;
			total += x[i];}
			}
			return total / nonmiss;
}

// [[Rcpp::export]]
double myMeanNACpp2Sugar(NumericVector x) {
                return mean(na_omit(x));
/*** R			
x_val <- rnorm(10)
x_val[c(3, 5)] <- NA
identical(myMeanNACpp2Sugar(x), 
          myMeanNACpp2(x))
*/
}

