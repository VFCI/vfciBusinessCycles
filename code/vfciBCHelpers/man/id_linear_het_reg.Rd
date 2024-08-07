% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/id_linear_het_reg.r
\name{id_linear_het_reg}
\alias{id_linear_het_reg}
\title{Use the fit of a linear regression estimating the heteroskedasticity
of the variance of the residuals in a VAR to identify a structural VAR.}
\usage{
id_linear_het_reg(
  var,
  target,
  het_reg_lags = 0,
  constant = TRUE,
  hetreg_method = "twostep",
  hetreg_horizon = 1,
  sign = "pos",
  sign_horizon = 1,
  method = "default",
  x2 = NULL,
  extra_data = NULL
)
}
\arguments{
\item{var}{a VAR, either vars::VAR or svars object}

\item{target}{variable in VAR to target with het_reg}

\item{het_reg_lags}{lags passed to het_reg}

\item{constant, }{boolean, default to TRUE for constant in het_reg regression}

\item{hetreg_method, }{defaults to "twostep", can change to "ML"}

\item{hetreg_horizon}{defaults to 1, number of periods to calculate the forecast error}

\item{sign}{Default to "positive". Can be "negative".  Ensures the
cummulative impact of the main shock on the target variable is the
given sign.}

\item{sign_horizon}{Default to 1. The horizon through which to accumulate the
impact of the shock.}

\item{method, }{"default" for our derivations for finding the q column,
and "mriv" to use Mertens and Ravn (2013) Appendix A IV derivations.}

\item{x2}{indepedent variables for predicting heteroskedasticity}

\item{extra_data}{additional data columns to cbind with the data from the VAR,}
}
\value{
SVAR
}
\description{
Use the fit of a linear regression estimating the heteroskedasticity
of the variance of the residuals in a VAR to identify a structural VAR.
}
