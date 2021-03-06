% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SuppressKDisclosure.R
\name{SuppressKDisclosure}
\alias{SuppressKDisclosure}
\title{K-disclosure suppression}
\usage{
SuppressKDisclosure(
  data,
  k = 1,
  dimVar = NULL,
  formula = NULL,
  hierarchies = NULL,
  freqVar = NULL,
  mc_function = X_from_mc,
  mc_hierarchies = NULL,
  upper_bound = Inf,
  ...
)
}
\arguments{
\item{data}{a data.frame representing the data set}

\item{k}{numeric vector of length one, representing possible size of
attacking coalition}

\item{dimVar}{The main dimensional variables and additional aggregating
variables. This parameter can be  useful when hierarchies and formula are
unspecified.}

\item{formula}{A model formula}

\item{hierarchies}{List of hierarchies, which can be converted by
\code{\link{AutoHierarchies}}. Thus, the variables can also be coded by
\code{"rowFactor"} or \code{""}, which correspond to using the categories in the data.}

\item{freqVar}{name of the frequency variable in \code{data}}

\item{mc_function}{a function for creating model matrix from mc_hierarchies}

\item{mc_hierarchies}{a hierarchy representing meaningful combinations to be
protected}

\item{upper_bound}{numeric value representing minimum count considered safe.
Default set to \code{Inf}}

\item{...}{parameters passed to children functions}
}
\value{
A data.frame containing the publishable data set, with a boolean
variable \verb{$suppressed} representing cell suppressions.
}
\description{
A function for suppressing frequency tables using the k-disclosure method.
}
\examples{
# data
mun <- c("k1", "k2", "k3", "k4", "k5", "k6")
inj <- c("serious", "light", "none", "unknown")
data <- expand.grid(mun, inj)
names(data) <- c("mun", "inj")
data$freq <- c(4,5,3,4,1,6,
0,0,2,1,0,0,
0,1,1,4,0,0,
0,0,0,0,0,0)

# hierarchies as DimLists
mun <- data.frame(levels = c("@", rep("@@", 6)), 
codes = c("Total", paste("k", 1:6, sep = "")))
inj <- data.frame(levels = c("@", "@@" ,"@@", "@@", "@@"), 
codes = c("Total", "serious", "light", "none", "unknown"))
dimlists <- list(mun = mun, inj = inj)

inj2 <- data.frame(levels = c("@", "@@", "@@@" ,"@@@", "@@", "@@"), 
codes = c("Total", "injured", "serious", "light", "none", "unknown"))
inj3 <- data.frame(levels = c("@", "@@", "@@" ,"@@", "@@"), 
codes = c( "shadowtotal", "serious", "light", "none", "unknown"))
mc_dimlist <- list(inj = inj2)
mc_nomargs <- list(inj = inj3)

#' # Example with formula, no meaningful combination
out <- SuppressKDisclosure(data, k = 1, freqVar = "freq", formula = ~mun*inj)

# Example with hierarchy and meaningful combination
out2 <- SuppressKDisclosure(data, k = 1, freqVar = "freq", 
hierarchies = dimlists, mc_hierarchies = mc_dimlist)

#' # Example of table without mariginals, and mc_hierarchies to protect
out3 <- SuppressKDisclosure(data, k = 1, freqVar = "freq",
formula = ~mun:inj, mc_hierarchies = mc_nomargs )
}
\author{
Daniel P. Lupp
}
