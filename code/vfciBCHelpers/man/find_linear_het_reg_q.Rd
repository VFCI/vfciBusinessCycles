% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/id_linear_het_reg.r
\name{find_linear_het_reg_q}
\alias{find_linear_het_reg_q}
\title{Return a single column vector of the Q rotation matrix.
Uses our own derivations with the het_reg as an IV.}
\usage{
find_linear_het_reg_q(var, het_reg, target)
}
\arguments{
\item{var}{a VAR}

\item{het_reg}{het_reg from fit_het_reg_from_var}

\item{target}{variable in VAR use to identify Q column}
}
\value{
A single column vector of the orthonormal matrix Q
}
\description{
Return a single column vector of the Q rotation matrix.
Uses our own derivations with the het_reg as an IV.
}
