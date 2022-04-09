
#' `spec` creation
#' 
#'  To make input to \code{\link{GaussSuppressionFromData}}  
#'  
#' Function `Spec` is a simple wrapper for \code{\link{list}}.  
#' Other functions are made for specific purposes.
#' 
#' @param ... Further arguments
#'
#' @return A named list of arguments to be used as `spec`  input to \code{\link{GaussSuppressionFromData}}.
#' @export
#'
#' @examples
#' SpecFrequency0A()
#' SpecFrequency0B()
#' identical(SpecFrequency0A(), SpecFrequency0C())
Spec <- function(...) {
  list(...)
}


#' @rdname Spec
#' @inheritParams GaussSuppressionFromData
#' @export
#'
SpecFrequency0A <- function(protectZeros = TRUE, extend0 = TRUE, primary = PrimaryDefault, candidates = CandidatesDefault,
                            singleton = SingletonDefault, ...) {
  mCall <- as.list(match.call())[-1]
  fCall <- formals()
  fCall$... <- NULL
  fCall[names(mCall)] <- mCall
  fCall
}

#' @rdname Spec
#' @export 
SpecFrequency0B <- function() {
  list(protectZeros = TRUE, extend0 = TRUE, primary = PrimaryDefault, candidates = CandidatesDefault, singleton = SingletonDefault)
  
}

#' @rdname Spec
#' @export 
SpecFrequency0C <- function() {
  list(protectZeros = TRUE, extend0 = TRUE, primary = as.name("PrimaryDefault"), candidates = as.name("CandidatesDefault"),
       singleton = as.name("SingletonDefault"))
  
}
  
  
#' SuppressFrequency
#'
#' @inheritParams GaussSuppressionFromData
#' @param ... Further arguments
#'
#' @export
#' @examples 
#' z1 <- SSBtoolsData("z1")
#' a1 <- GaussSuppressionFromData(data = z1, dimVar = 1:2, freqVar = 3, spec = SpecFrequency0A())
#' a2 <- SuppressFrequency(data = z1, dimVar = 1:2, freqVar = 3)
#' a3 <- SuppressFrequency0A(data = z1, dimVar = 1:2, freqVar = 3)
#' a4 <- SuppressFrequency0B(data = z1, dimVar = 1:2, freqVar = 3)
#' a5 <- SuppressFrequency0_non_spec(data = z1, dimVar = 1:2, freqVar = 3)
#' identical(a1, a2)
#' identical(a1, a3)
#' identical(a1, a4)
#' identical(a1, a5)
SuppressFrequency <- function(data, dimVar = NULL, freqVar = NULL, maxN = 3, spec = SpecFrequency0A(), ...) {
  GaussSuppressionFromData(data = data, dimVar = dimVar, freqVar = freqVar, maxN = maxN, spec = spec, ...)
}

#' @rdname SuppressFrequency
#' @export 
SuppressFrequency0A <- function(..., spec = SpecFrequency0A()) {
  GaussSuppressionFromData(..., spec = spec)
}

#' @rdname SuppressFrequency
#' @export 
SuppressFrequency0B <- function(..., spec = SpecFrequency0B()) {
  GaussSuppressionFromData(..., spec = spec)
}

#' @rdname SuppressFrequency
#' @export 
SuppressFrequency0_non_spec <- function(..., protectZeros = TRUE, extend0 = TRUE, primary = PrimaryDefault, candidates = CandidatesDefault, singleton = SingletonDefault) {
  GaussSuppressionFromData(..., protectZeros = protectZeros, extend0 = extend0, primary = primary, candidates = candidates, singleton = singleton)
}
