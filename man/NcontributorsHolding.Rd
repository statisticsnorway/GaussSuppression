% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Ncontributors.R
\name{NcontributorsHolding}
\alias{NcontributorsHolding}
\title{\code{\link{Ncontributors}} with holding-indicator}
\usage{
NcontributorsHolding(x, groups, holdingInd = NULL)
}
\arguments{
\item{x}{A (sparse) dummy matrix}

\item{groups}{Vector of group categories}

\item{holdingInd}{Vector of holding group categories}
}
\value{
Vector of numbers of unique groups
}
\description{
The aggregates (columns of \code{x}) are grouped by a holding indicator.
Within each holding group, the number of unique groups (output) is set to be equal.
}
\details{
A representative within the holding group is used to calculate output by \code{\link{Ncontributors}}.
The one with maximal column sum of \code{x} is chosen as the representative.
Normally this will be an aggregate representing the holding group total.
When holdingInd is NULL (default), the function is equivalent to \code{\link{Ncontributors}}.
}
\author{
Øyvind Langsrud
}
