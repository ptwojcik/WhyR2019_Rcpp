#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
List colCVsCpp_list(NumericMatrix x) {
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
   
   // List object can be created with List::create() function
   // element names can be assigned with Named() function or _[].
   List result = List::create(Named("means") = means_x ,
                              _["sds"] = sds,
							  _["cvs"] = colCVs);
   
   // or just:
   // List result = List::create(means_x, sds, colCVs)
   // if names do not have to be assigned manually
   
   return(result);
}