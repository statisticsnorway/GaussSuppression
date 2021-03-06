#' K-disclosure suppression
#' 
#' A function for suppressing frequency tables using the k-disclosure method.
#' 
#' @param data a data.frame representing the data set
#' @param k numeric vector of length one, representing possible size of
#' attacking coalition
#' @param dimVar The main dimensional variables and additional aggregating
#' variables. This parameter can be  useful when hierarchies and formula are
#' unspecified. 
#' @param formula A model formula
#' @param hierarchies List of hierarchies, which can be converted by 
#' \code{\link{AutoHierarchies}}. Thus, the variables can also be coded by 
#' `"rowFactor"` or `""`, which correspond to using the categories in the data.
#' @param freqVar name of the frequency variable in `data`
#' @param mc_function a function for creating model matrix from mc_hierarchies
#' @param mc_hierarchies a hierarchy representing meaningful combinations to be
#' protected
#' @param upper_bound numeric value representing minimum count considered safe.
#' Default set to `Inf`
#' @param ... parameters passed to children functions
#'
#' @return A data.frame containing the publishable data set, with a boolean
#' variable `$suppressed` representing cell suppressions.
#' @export
#' 
#' @author Daniel P. Lupp

#' @examples
#' # data
#' mun <- c("k1", "k2", "k3", "k4", "k5", "k6")
#' inj <- c("serious", "light", "none", "unknown")
#' data <- expand.grid(mun, inj)
#' names(data) <- c("mun", "inj")
#' data$freq <- c(4,5,3,4,1,6,
#' 0,0,2,1,0,0,
#' 0,1,1,4,0,0,
#' 0,0,0,0,0,0)
#' 
#' # hierarchies as DimLists
#' mun <- data.frame(levels = c("@@", rep("@@@@", 6)), 
#' codes = c("Total", paste("k", 1:6, sep = "")))
#' inj <- data.frame(levels = c("@@", "@@@@" ,"@@@@", "@@@@", "@@@@"), 
#' codes = c("Total", "serious", "light", "none", "unknown"))
#' dimlists <- list(mun = mun, inj = inj)
#' 
#' inj2 <- data.frame(levels = c("@@", "@@@@", "@@@@@@" ,"@@@@@@", "@@@@", "@@@@"), 
#' codes = c("Total", "injured", "serious", "light", "none", "unknown"))
#' inj3 <- data.frame(levels = c("@@", "@@@@", "@@@@" ,"@@@@", "@@@@"), 
#' codes = c( "shadowtotal", "serious", "light", "none", "unknown"))
#' mc_dimlist <- list(inj = inj2)
#' mc_nomargs <- list(inj = inj3)
#' 
#' #' # Example with formula, no meaningful combination
#' out <- SuppressKDisclosure(data, k = 1, freqVar = "freq", formula = ~mun*inj)
#' 
#' # Example with hierarchy and meaningful combination
#' out2 <- SuppressKDisclosure(data, k = 1, freqVar = "freq", 
#' hierarchies = dimlists, mc_hierarchies = mc_dimlist)
#' 
#' #' # Example of table without mariginals, and mc_hierarchies to protect
#' out3 <- SuppressKDisclosure(data, k = 1, freqVar = "freq",
#' formula = ~mun:inj, mc_hierarchies = mc_nomargs )
SuppressKDisclosure <- function(data,
                                k = 1,
                                dimVar = NULL,
                                formula = NULL,
                                hierarchies = NULL,
                                freqVar = NULL,
                                mc_function = X_from_mc,
                                mc_hierarchies = NULL,
                                upper_bound = Inf,
                                ...) {
  if (!is.function(mc_function))
    stop("Parameter mc_function must be a function.")
  additional_params <- list(...)
  if (length(additional_params)) {
    if ("singletonMethod" %in% names(additional_params) & 
        "none" %in% additional_params[["singletonMethod"]])
    warning("SuppressKDisclosure should use a singleton method for protecting the zero singleton problem. The output might not be safe, consider rerunning with a singleton method (default).")
  }
  GaussSuppressionFromData(data,
                           hierarchies = hierarchies,
                           formula = formula,
                           dimVar = dimVar,
                           freqVar = freqVar,
                           k = k,
                           mc_hierarchies = mc_hierarchies,
                           mc_function = mc_function,
                           upper_bound = upper_bound,
                           primary = KDisclosurePrimary,
                           candidates = DirectDisclosureCandidates,
                           protectZeros = FALSE,
                           secondaryZeros = 1,
                           ...)
}

#' Construct primary suppressed difference matrix
#' 
#' Function for constructing model matrix columns representing primary suppressed
#' difference cells
#'
#' @inheritParams SuppressKDisclosure
#' @inheritParams DominanceRule

#'
#' @return dgCMatrix corresponding to primary suppressed cells
#' @export
KDisclosurePrimary <- function(data,
                               x,
                               crossTable,
                               mc_function,
                               mc_hierarchies,
                               freqVar,
                               k = 1,
                               upper_bound, ...) {
  x <- cbind(x, mc_function(data = data,
                            x = x,
                            crossTable = crossTable,
                            mc_hierarchies = mc_hierarchies,
                            freqVar = freqVar,
                            k = k,
                            upper_bound = upper_bound,
                            ...
                            ))
  x <- x[, !SSBtools::DummyDuplicated(x, rnd = TRUE), drop = FALSE]
  freq <- as.vector(crossprod(x, data[[freqVar]]))
  find_difference_cells(x = x,
                        freq = freq,
                        k = k,
                        upper_bound = upper_bound)
}

find_difference_cells <- function(x,
                                  freq,
                                  k,
                                  upper_bound = Inf) {
  publ_x <- crossprod(x)
  publ_x <- as(publ_x, "dgTMatrix")
  colSums_x <- colSums(x)
  # row i is child of column j in r
  r <- colSums_x[publ_x@i + 1] == publ_x@x & colSums_x[publ_x@j + 1] != publ_x@x
  publ_x@x <- publ_x@x[r]
  publ_x@j <- publ_x@j[r]
  publ_x@i <- publ_x@i[r]
  child_parent <- cbind(child = publ_x@i + 1,
                        parent = publ_x@j + 1,
                        diff = freq[publ_x@j + 1] - freq[publ_x@i + 1])
  child_parent <- child_parent[freq[child_parent[,2]] > 0 &
                                 freq[child_parent[,1]] > 0 & 
                                 freq[child_parent[,1]] <= upper_bound,]
  disclosures <- child_parent[child_parent[,3] <= k, ]
  if (nrow(disclosures))
    primary_matrix <- as(apply(disclosures,
                               1,
                               function(row) x[,row[2]] - x[,row[1]]),
                         "dgTMatrix")
  else primary_matrix <- NULL
  primary_matrix
}
