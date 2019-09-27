#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
DataFrame colCVsCpp_df2(NumericMatrix x) {
   int n = x.nrow(), ncol = x.ncol();
   NumericMatrix x2(n, ncol);
   NumericVector means_x(ncol), means_x2(ncol), 
                 sds(ncol), colCVs(ncol);
   // raise all elements of matrix x to power 2
   // loop over columns
   for (int j = 0; j < ncol; j++) {
	   x2( _ , j ) = pow(x( _ , j ), 2);
	   }
   means_x = colMeans(x);
   means_x2 = colMeans(x2);
   sds = sqrt( double(n)/(n-1) * (means_x2 - pow(means_x, 2.0)) );
   colCVs = 100 * sds/means_x;
   
   // DataFrame object can be created with DataFrame::create() function
   // column names can be assigned with Named() function or _[].
   DataFrame result = List::create(Named("means") = clone(means_x) ,
                                   _["sds"] = clone(sds),
							       _["cvs"] = clone(colCVs),
							       _["cvs2"] = colCVs);
   
   // lets in the end fill the colCVs vector with zeroes
   colCVs = rep(0, colCVs.size());
   
   return(result);
}