
# This function is made to handle cases with extend0all and cases with special hierarchies (unnamed list) so that SSBtools:::NamesFromHierarchies before and after AutoHierarchies differ. 
# A straightforward handling of the latter means that some  dimVar become extraVar. Then if they are numeric, they will be set to 0. This function change this to NA (maybe NA can be solved by future parameter to Extend0 ).
# Hopefully this function also avoids that dimVar become extraVar.  I general hierarchical relationships are described by hierarchies and not data. But when data are used to generate (parts of) the hierarchies, data may be used.
# All the code made to avoid dimVar become extraVar have no practical consequences for standard use of GaussSuppressionFromData. The code is relevant  when "inner" is included in output.
# This function may be a future function in SSBtools. Then dimVar is not needed in input. Instead found by  SSBtools:::NamesFromHierarchies


#' @importFrom SSBtools HierarchicalGroups2
Extend0fromHierarchies <- function(data, freqName, hierarchies, dimVar, extend0all, ...) {
  
  toFindDimLists <- (names(hierarchies) %in% c(NA, "")) & (sapply(hierarchies, is.character))  # toFindDimLists created exactly as in AutoHierarchies
  all_toFindDimLists <- unique(unlist(hierarchies[toFindDimLists]))
  
  hierarchies <- AutoHierarchies(hierarchies = hierarchies, data = data, ...)
  dVar <- dimVar  # as in code before separate function
  dVar_ <- names(hierarchies)
  
  varGroups <- as.list(dVar_)  # This is standard in Extend0 when !hierarchical
  for (i in seq_along(varGroups)) {
    varGroups[[i]] <- unique(data[varGroups[[i]]])  # This is standard in Extend0
  }
  
  if (extend0all) {
    for (i in seq_along(varGroups)) {
      mapsFrom <- unique(hierarchies[[dVar_[i]]]$mapsFrom)
      mapsTo <- unique(hierarchies[[dVar_[i]]]$mapsTo)
      mapsExtra <- mapsFrom[!(mapsFrom %in% mapsTo)]
      mapsExtra <- mapsExtra[!(mapsExtra %in% varGroups[[i]][[1]])]
      if (length(mapsExtra)) {
        extra_varGroups_i <- varGroups[[i]][rep(1, length(mapsExtra)), , drop = FALSE]
        extra_varGroups_i[[1]] <- mapsExtra
        varGroups[[i]] <- rbind(varGroups[[i]], extra_varGroups_i)
      }
    }
  }
  if (length(dVar_) < length(dVar)) {
    varGroups_special <- HierarchicalGroups2(data[all_toFindDimLists])
    if (is.null(names(varGroups))) {
      names(varGroups) <- unlist(lapply(varGroups, names))
    }
    varGroups_special <- varGroups_special[names(varGroups_special) %in% names(varGroups)]
    removenames <- unique(unlist(varGroups_special))
    removenames <- removenames[!(removenames %in% names(varGroups_special))]
    removenames <- removenames[(removenames %in% names(varGroups))]
    for (i in seq_along(varGroups_special)) {
      varGroups_special[[i]] <- varGroups_special[[i]][!(varGroups_special[[i]] %in% removenames)]
    }
    varGroups_special <- varGroups_special[unlist(lapply(varGroups_special, length)) > 1]
    if (length(varGroups_special)) {
      dVar_ <- unique(c(dVar_, unlist(varGroups_special)))
      for (i in seq_along(varGroups_special)) {
        varGroups_special[[i]] <- unique(data[varGroups_special[[i]]])  # This is standard in Extend0
      }
    }
    ma <- match(names(varGroups_special), names(varGroups))
    for (i in seq_along(varGroups_special)) {
      if (nrow(varGroups[[ma[i]]]) == nrow(varGroups_special[[i]])) {
        varGroups[[ma[i]]] <- varGroups_special[[i]]
      }
    }
  }
  
  nrowPreExtend0 <- nrow(data)
  
  data <- Extend0(data, freqName = freqName, dimVar = NULL, varGroups = varGroups, extraVar = TRUE, hierarchical = FALSE)
  
  # Set to NA instead of 0 for possible numeric dimVar not in hierarchy after AutoHierarchies (above)
  if (length(dVar_) < length(dVar)) {
    warning("Some dimVar columns set to NA in extended part of data")
    extra_dVar <- dVar[!(dVar %in% dVar_)]
    extra_dVar <- extra_dVar[sapply(data[1, extra_dVar], is.numeric)]
    if (length(extra_dVar)) {
      newrows <- SeqInc(nrowPreExtend0 + 1L, nrow(data))
      if (length(newrows)) {
        data[newrows, extra_dVar] <- NA
      }
    }
  }
  list(data = data, hierarchies = hierarchies)
}
