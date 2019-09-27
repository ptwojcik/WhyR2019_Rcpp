#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
S4 creates4clientCpp(String fname,
                     String lname,
                     String occupation,
                     int age,
                     bool married,
                     Date date){ 
  
  // Creating an object of Person class
  S4 x("client");
  
  // Setting values to the slots
  x.slot("fname") = fname;
  x.slot("lname") = lname;
  x.slot("occupation") = occupation;
  x.slot("age") = age;
  x.slot("married") = married;
  x.slot("first_registered") = date;
  
  return(x);
}

