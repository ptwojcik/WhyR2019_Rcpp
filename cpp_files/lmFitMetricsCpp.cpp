#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
DataFrame lmFitMetricsCpp(List model_lm) {
    
   // Lets check if input is an object of class lm(),
   // if not - stop and print an appropriate message
   // object.inherits(str) returns true if object 
   // inherits the class specified by the string str
   if (! model_lm.inherits("lm")) 
         stop("The argument must be a lm() model result.");

   // to extract the element from the list
   // or data.frame in C++ one can use:
   // NumericVector v1 = df[0];
   // NumericVector v2 = df["V2"];
   
   NumericVector forecast = model_lm["fitted.values"];
   // lets also create a vector of residuals
   NumericVector resid = model_lm["residuals"];
   NumericVector real = forecast + resid;
   
   NumericVector absresid = abs(resid);
     
   // Mean Square Error
   double MSE = mean(pow(resid, 2));
   // Root Mean Square Error
   double RMSE = sqrt(MSE);
   // Mean Absolute Error
   double MAE = mean(absresid);
   // Mean Absolute Percentage Error
   double MAPE = mean(absresid/real);
   // Adjusted Mean Absolute Percentage Error
   double AMAPE = mean(absresid/(real + forecast));
   // Median Absolute Error - sugar function media()
   double MedAE = median(absresid);
   // Mean Logarithmic Absolute Error
   double MSLE = mean(pow(log(1 + real) - log(1 + forecast), 2));
   // Total Sum of Squares
   double TSS = sum(pow(real - mean(real), 2));
   // Explained Sum of Squares
   double RSS = sum(pow(forecast - real, 2));
   // R2
   double R2 = 1 - double(RSS)/TSS;
   // it does not work if the result is not named
   // giving an error during execution: 
   // Not compatible with STRSXP: [type=NULL]
   DataFrame result = DataFrame::create(_["MSE"] = MSE,
                                        _["RMSE"] = RMSE,
                                        _["MAE"] = MAE,
                                        _["MAPE"] = MAPE, 
                                        _["AMAPE"] = AMAPE,
                                        _["MedAE"] = MedAE,
                                        _["MSLE"] = MSLE,
                                        _["R2"] = R2);
   return(result);
}